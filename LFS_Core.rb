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
  @error_log = []

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

  def self.error_log
    [].replace @error_log
  end

  def self.clear_dialogues
    @dialogues = {}
    @dialogue_options = {}
  end

  def self.add_dialogue(id, text)
    @dialogues[id] = text
  end

  def self.set_dialogue_options(id, options)
    validate_dialogue_options(options)

    @dialogue_options[id] = options
  end

  def self.validate_dialogue_options(options)
    options.each do |key, value|
      unless [:face_name, :face_index, :position, :background].include?(key)
        fail ArgumentError, "Invalid dialogue option '#{key}'"
      end
      case key
      when :face_name
        unless options.key?(:face_index)
          fail ArgumentError, "'face_name' specified without 'face_index'!"
        end
      when :face_index
        unless (0..7).cover?(value)
          fail ArgumentError, "'face_index' must be between 0 and 7"
        end
        unless options.key?(:face_name)
          fail ArgumentError, "'face_index' specified without 'face_name'!"
        end
      when :position
        unless %w(top middle bottom).include?(value)
          fail ArgumentError, "'position' must be 'top', 'middle' or 'bottom'"
        end
      when :background
        unless %w(normal dim transparent).include?(value)
          fail ArgumentError,
               "'background' must be 'normal', 'dim' or 'transparent'"
        end
      end
    end
  end

  def self.load_rvtext(filename)
    @dialogues = {}
    open(filename, 'r:UTF-8') do |f|
      current_id = nil
      current_text = ''
      f.each_line do |l|
        next if l.start_with?('#') # Ignore comment lines
        if (m = ENTRY_METADATA.match(l))
          add_dialogue(current_id, current_text.rstrip)  if current_id
          current_id = m[1]
          current_text = ''
        else
          current_text += l
        end
      end
      add_dialogue(current_id, current_text.rstrip) unless current_text == ''
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
