#==============================================================================
#
# Language File System - Core Script
# Version 2.0
# Last Update: March 8th, 2014
# Author: DerTraveler (dertraveler [at] gmail.com)
#
#==============================================================================

$imported = {} if $imported.nil?
$imported[:LanguageFileSystem_Core] = true

#==============================================================================
module LanguageFileSystem
  #############################################################################
  #
  # Do not edit past this point, if you have no idea, what you're doing ;)
  #
  #############################################################################

  CURRENT_VERSION = 20

  @dialogues = {}
  @dialogue_options = {}

  @log_context = {}
  @log = []

  # Regexps for the special commands used in Messages
  DIALOGUE_CODE = /\\dialogue(!)?\[([^\]]+)\]/

  # Filenames
  DIALOGUE_FILE_PREFIX = 'Dialogues'
  RVTEXT_EXT = 'rvtext'

  # File entry format Regexp
  ENTRY_METADATA = /^<<([^>]+)>>$/

  def self.dialogues
    {}.replace @dialogues
  end

  def self.dialogue_options
    {}.replace @dialogue_options
  end

  def self.log
    [].replace @log
  end

  def self.clear_dialogues
    @dialogues = {}
    @dialogue_options = {}
  end

  def self.add_dialogue(id, text)
    @dialogues[id] = text
  end

  def self.set_dialogue_options(id, options)
    @dialogue_options[id] = options
  end

  def self.clear_log_context
    @log_context = {}
  end

  def self.log_warning(message, data = {})
    @log += [@log_context.merge(type: :warning).merge(data).merge(msg: message)]
  end

  def self.log_error(message, data = {})
    @log += [@log_context.merge(type: :error).merge(data).merge(msg: message)]
  end

  DIALOGUE_ID = /<<([^>]+)>>/
  DIALOGUE_OPT = /<<([^:>]+):([^>]+)>>/

  def self.load_dialogues_rvtext(filename)
    clear_dialogues

    open(filename, 'r:UTF-8') do |f|
      @log_context[:file] = filename
      @log_context[:line] = 0

      current_id = nil
      current_text = ''
      current_options = {}

      message_start_line = nil

      f.each_line do |l|
        @log_context[:line] += 1

        next if l.start_with?('#') # Ignore comment lines
        case l
        when DIALOGUE_OPT
          validate_dialogue_option(current_options, $1.strip, $2.strip)
        when DIALOGUE_ID # start of new message
          if current_id
            if current_text.empty?
              log_warning("Message with id '#{current_id}' is empty!",
                          line: message_start_line)
            end
            add_dialogue(current_id, current_text.rstrip)
            set_dialogue_options(current_id, current_options)
          end
          current_id = $1
          current_text = ''
          current_options = {}
          message_start_line = @log_context[:line]
        else
          current_text += l
        end
      end

      # Add last dialogue
      if current_id
        add_dialogue(current_id, current_text.rstrip)
        set_dialogue_options(current_id, current_options)
      end
    end

    clear_log_context
  end

  DIALOGUE_HEADER = /# LFS DIALOGUES VERSION (\d+)/

  def self.versioncheck_dialogues_rvtext(filename)
    header = nil
    content = nil
    version = 10

    open(filename, 'r:UTF-8') do |f|
      header, sep, content = f.read.partition("\n")
      if (m = DIALOGUE_HEADER.match(header))
        version = m[1].to_i
      else
        # If the header does not exist, then the first line is part of then
        # normal file content - so it needs to be added again
        content = header + sep + content
        header = nil
      end
    end

    unless version == CURRENT_VERSION
      # Backup old file
      open(filename + '_backup', 'w:UTF-8') do |backup|
        backup.write(header + "\n") if header
        backup.write(content)
      end
      # Convert to current version
      content = update_dialogues_rvtext(version, content)
      open(filename, 'w:UTF-8') do |f|
        f.write("# LFS DIALOGUES VERSION #{CURRENT_VERSION}\n")
        f.write(content)
      end
      msgbox "Dialogues have been updated to current file format.\n" \
             "The original file was renamed to '#{filename}_backup'"
    end
  end

  MSG_POS = %w(top middle bottom)
  MSG_BG = %w(normal dim transparent)

  def self.page_to_rvtext(prefix, commands, with_options = false)
    entries = []
    new_commands = []

    i = 0
    current_id = ''
    current_entry = ''
    last_code = 0
    commands.each do |c|
      case c.code
      when 101
        entries <<= current_entry unless current_entry.empty?
        i += 1
        current_id = format("#{prefix}%03d", i)
        current_entry = "<<#{current_id}>>\n"
        if with_options
          current_entry += "<<face: #{c.parameters[0]}," \
                           " #{c.parameters[1]}>>\n" \
                             unless c.parameters[0] == ''
          current_entry += '<<background:' \
                           " #{MSG_BG[c.parameters[2]]}>>\n" \
                             unless c.parameters[2] == 0
          current_entry += '<<position:' \
                           " #{MSG_POS[c.parameters[3]]}>>\n" \
                             unless c.parameters[3] == 2
        end
        new_commands <<= c
      when 401
        current_entry += c.parameters[0] + "\n"
        tag = with_options ? 'dialogue!' : 'dialogue'
        new_commands <<= RPG::EventCommand.new(401, c.indent,
                                               ["\\#{tag}[#{current_id}]"]) \
          unless last_code == 401
      when 102
        entries <<= current_entry unless current_entry.empty?
        i += 1
        current_id = format("#{prefix}%03d", i)
        current_entry = ''
        new_choices = []
        c.parameters[0].each_index do |k|
          current_entry += "<<#{current_id}-#{k}>>\n#{c.parameters[0][k]}\n"
          new_choices <<= "\\dialogue[#{current_id}-#{k}]"
        end
        new_commands <<= RPG::EventCommand.new(102, c.indent,
                                               [new_choices, c.parameters[1]])
      else
        new_commands <<= c
      end
      last_code = c.code
    end
    entries <<= current_entry unless current_entry.empty?

    [entries, new_commands]
  end

  #=============================================================================
  # ** LanguageFileSystem (private methods)
  #-----------------------------------------------------------------------------
  # These methods are used internally and should not be used directly unless you
  # know what you do ;)
  #
  # Methods: validate_dialogue_option
  #=============================================================================
  class << self
    private

    def validate_dialogue_option(options, key, value)
      case key.strip
      when 'face'
        name, id = value.split(',')
        case
        when !id
          log_error('Index of face not specified!')
        when !(0..7).cover?(id.to_i)
          log_error('Index of face must be between 0 and 7!')
        else
          options[:face_name] = name.strip
          options[:face_index] = id.to_i
        end
      when 'position'
        case value
        when *MSG_POS # One of the elements of MSG_POS
          options[:position] = value
        else
          log_error("'position' must be 'top', 'middle' or 'bottom'")
        end
      when 'background'
        case value
        when *MSG_BG # One of the elements of MSG_BG
          options[:background] = value
        else
          log_error("'background' must be 'normal', 'dim' or 'transparent'")
        end
      when 'scroll_speed'
        case
        when (1..8).cover?(value.to_i)
          options[:scroll_speed] = value.to_i
        else
          log_error("'scroll_speed' must be between 1 and 8!")
        end
      when 'scroll_no_fast'
        case value
        when 'true', 'false'
          options[:scroll_no_fast] = value == 'true'
        else
          log_error("'scroll_no_fast' must be 'true' or 'false'")
        end
      else
        log_error("Invalid dialogue option '#{key}'")
      end
    end

    def update_dialogues_rvtext(version, content)
      result = String.new(content)

      result.gsub!('<<no_fast>>', '<<scroll_fast: true>>') if version < 20

      result
    end
  end
end

#==============================================================================
# ** Game_Message
#------------------------------------------------------------------------------
# Add support for the \dialogues message code.
#
# Changes:
#   alias: add, clear
#   new: set_message_options
#==============================================================================
class Game_Message
  alias lfs_add add
  def add(text)
    if (m = LanguageFileSystem::DIALOGUE_CODE.match(text))
      line = LanguageFileSystem.dialogues[m[2]]
      if line
        @texts = []
        lfs_add(line)

        if m[1] == '!' # If it's the \dialogue![...] tag then use options
          options = LanguageFileSystem.dialogue_options[m[2]]
          set_message_options(options) if options
        end

        @message_replaced = true
      end
    end
    lfs_add(text) unless @message_replaced
  end

  def set_message_options(options)
    @face_name = options[:face_name] if options.key?(:face_name)
    @face_index = options[:face_index] if options.key?(:face_index)
    @position = LanguageFileSystem::MSG_POS.index(options[:position]) \
      if options.key?(:position)
    @background = LanguageFileSystem::MSG_BG.index(options[:background]) \
      if options.key?(:background)
    @scroll_speed = options[:scroll_speed] if options.key?(:scroll_speed)
    @scroll_no_fast = options[:scroll_no_fast] == 'true' \
      if options.key?(:scroll_no_fast)
  end

  alias lfs_clear clear
  def clear
    lfs_clear
    @message_replaced = false
  end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
# Add support for the \dialogues message code in choices.
#
# Changes:
#   alias: setup_choices
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Parse for \dialogue[...] and replace choice content if found.
  #--------------------------------------------------------------------------
  alias lfs_setup_choices setup_choices
  def setup_choices(params)
    choices = Array.new(params[0])
    (0...choices.length).each do |i|
      next unless (m = LanguageFileSystem::DIALOGUE_CODE.match(choices[i]))

      line = LanguageFileSystem.dialogues[m[2]]
      choices[i] = line.split("\n")[0] if line
    end
    lfs_setup_choices([choices] + params[1..-1])
  end
end
