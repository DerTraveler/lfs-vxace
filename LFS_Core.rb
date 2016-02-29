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

  @dialogues = {}
  @dialogue_options = {}

  @log_context = {}
  @log = []

  # Regexps for the special commands used in Messages
  DIALOGUE_CODE = /\\dialogue\[([^\]]+)\]/

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

  def self.load_rvtext(filename)
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
        when 'top', 'middle', 'bottom'
          options[:position] = value
        else
          log_error("'position' must be 'top', 'middle' or 'bottom'")
        end
      when 'background'
        case value
        when 'normal', 'dim', 'transparent'
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
      line = LanguageFileSystem.dialogues[m[1]]
      if line
        @texts = []
        lfs_add(line)

        options = LanguageFileSystem.dialogue_options[m[1]]
        set_message_options(options) if options

        @message_replaced = true
      end
    end
    lfs_add(text) unless @message_replaced
  end

  def set_message_options(options)
    @face_name = options[:face_name] if options.key?(:face_name)
    @face_index = options[:face_index] if options.key?(:face_index)
    @position = %w(top middle bottom).index(options[:position]) \
      if options.key?(:position)
    @background = %w(normal dim transparent).index(options[:background]) \
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

      line = LanguageFileSystem.dialogues[m[1]]
      choices[i] = line.split("\n")[0] if line
    end
    lfs_setup_choices([choices] + params[1..-1])
  end
end
