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
  @database = {}

  @log_context = {}
  @log = []

  # Regexp for the special commands used in Messages
  DIALOGUE_CODE = /\\dialogue(!)?\[([^\]]+)\]/
  # Regexp for the name commands used in Change (Nick)name command
  NAME_CODE = /\\name\[([^\]]+)\]/

  # Filenames
  DIALOGUE_FILE_PREFIX = 'Dialogues'
  RVTEXT_EXT = 'rvtext'

  # Mapping between indexes used in RPG Maker and literal parameters
  MSG_POS = %w(top middle bottom)
  MSG_BG = %w(normal dim transparent)

  class << self
    def dialogues
      {}.replace @dialogues
    end

    def dialogue_options
      {}.replace @dialogue_options
    end

    def database
      {}.replace @database
    end

    # Directory where extracted files are being created
    EXTRACTED_DIR = 'Extracted'

    # Extracts all dialogues and choices from all events and replaces all
    # extracted content with the corresponding dialogue tags.
    # The created files are stored in a subdirectory called Extracted.
    def export_rvtext
      begin
        Dir.mkdir(EXTRACTED_DIR)
      rescue SystemCallError
        msgbox "There is already an 'Extracted' directory. Please move\n" \
               'or delete it and try again'
        return
      end
      Dir.mkdir("#{EXTRACTED_DIR}/Data")
      open("#{EXTRACTED_DIR}/#{DIALOGUE_FILE_PREFIX}Extracted.#{RVTEXT_EXT}",
           'w:UTF-8') do |output|
        map_infos = load_data('Data/MapInfos.rvdata2')
        map_infos.each_key do |m_id|
          map_prefix = format("M%03d#{clean_for_id(map_infos[m_id].name, 8)}/",
                              m_id)
          map = load_data(format('Data/Map%03d.rvdata2', m_id))
          map.events.each_key do |e_id|
            event = map.events[e_id]
            event_prefix = format("%03d#{clean_for_id(event.name, 7)}/", e_id)
            event.pages.each_index do |p_id|
              dialogues, _, new_list = \
                extract_page(format("#{map_prefix + event_prefix}%02d/",
                                    p_id + 1),
                             event.pages[p_id].list)
              event.pages[p_id].list = new_list
              create_rvtext(dialogues).each { |entry| output.write(entry) }
            end
          end
          save_data(map, format("#{EXTRACTED_DIR}/Data/Map%03d.rvdata2", m_id))
        end

        common_events = load_data('Data/CommonEvents.rvdata2')
        common_events.each do |c_event|
          next unless c_event
          dialogues, _, new_list = \
            extract_page(format("C%03d#{clean_for_id(c_event.name, 15)}/",
                                c_event.id),
                         c_event.list)
          c_event.list = new_list
          create_rvtext(dialogues).each { |entry| output.write(entry) }
        end
        save_data(common_events, "#{EXTRACTED_DIR}/Data/CommonEvents.rvdata2")

        troops = load_data('Data/Troops.rvdata2')
        troops.each do |t|
          next unless t
          t_prefix = format("B%03d#{clean_for_id(t.name, 15)}/", t.id)
          t.pages.each_index do |p_id|
            dialogues, _, new_list = \
              extract_page(format("#{t_prefix}%02d/", p_id + 1),
                           t.pages[p_id].list)
            t.pages[p_id].list = new_list
            create_rvtext(dialogues).each { |entry| output.write(entry) }
          end
        end
        save_data(troops, "#{EXTRACTED_DIR}/Data/Troops.rvdata2")
      end
    end

    #==========================================================================
    # ** LanguageFileSystem (private methods)
    #--------------------------------------------------------------------------
    # These methods are used internally and should not be used directly unless
    # you know what you do ;)
    #==========================================================================

    private

    #------------------------------------------------------------------------
    # * Getters/Setters for internal data structures
    #------------------------------------------------------------------------

    def clear_dialogues
      @dialogues = {}
      @dialogue_options = {}
    end

    def add_dialogue(id, text)
      @dialogues[id] = text
    end

    def set_dialogue_options(id, options)
      @dialogue_options[id] = options
    end

    def clear_database
      @database = new_empty_database
    end

    def new_empty_database
      { actors: { name: {}, description: {}, note: {}, nickname: {} },
        names: {} }
    end

    def clear_log_context
      @log_context = {}
    end

    def log
      [].replace @log
    end

    def clear_log
      @log = []
    end

    def log_warning(message, data = {})
      @log += \
        [@log_context.merge(type: :warning).merge(data).merge(msg: message)]
    end

    def log_error(message, data = {})
      @log += [@log_context.merge(type: :error).merge(data).merge(msg: message)]
    end

    # Checks the given key and value for validity.
    # If valid then they are added to the given option hash.
    # Otherwise an error will be added to the log.
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

    #------------------------------------------------------------------------
    # * Methods related to the rvtext file format
    #------------------------------------------------------------------------
    DIALOGUE_ID = /<<([^>]+)>>/
    DIALOGUE_OPT = /<<([^:>]+):([^>]+)>>/

    # Loads the dialogues and options from the given rvtext file.
    def load_dialogues_rvtext(filename)
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

    UPDATED_DIR = 'Updated'
    DIALOGUE_HEADER = /# LFS DIALOGUES VERSION (\d+)/

    # Checks whether the given DialoguesXXX.rvtext file has the most recent
    # version. If that's not the case then update the file.
    def versioncheck_dialogues_rvtext(filename)
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

      return if version == CURRENT_VERSION
      Dir.mkdir(UPDATED_DIR) unless Dir.exist?(UPDATED_DIR)

      # Convert to current version
      content = update_dialogues_rvtext(version, content)
      open("#{UPDATED_DIR}/#{filename}", 'w:UTF-8') do |f|
        f.write("# LFS DIALOGUES VERSION #{CURRENT_VERSION}\n")
        f.write(content)
      end
    end

    # Updating content of DialoguesXXX.rvtext that has the given version to the
    # most current version
    def update_dialogues_rvtext(version, content)
      result = String.new(content)

      result.gsub!('<<no_fast>>', '<<scroll_fast: true>>') if version < 20

      result
    end

    # Creates an array of rvtext entries out of dialogue and option hashes.
    # These entries can be directly written/appended to a rvtext file.
    def create_rvtext(dialogues, options = nil)
      result = []
      dialogues.each do |id, entry|
        header = "<<#{id}>>\n"
        if options && options[id]
          header += "<<face: #{options[id][:face_name]}," \
                    " #{options[id][:face_index]}>>\n" \
            if options[id][:face_index]
          header += "<<background: #{options[id][:background]}>>\n" \
            if options[id][:background]
          header += "<<position: #{options[id][:position]}>>\n" \
            if options[id][:position]
          header += "<<scroll_speed: #{options[id][:scroll_speed]}>>\n" \
            if options[id][:scroll_speed]
          header += "<<scroll_no_fast: #{options[id][:scroll_no_fast]}>>\n" \
            if options[id][:scroll_no_fast]
        end
        result <<= "#{header}#{entry}\n"
      end
      result
    end

    # Updates pages produced by the old extractions method
    # (prior to version 2.0)
    def update_page(commands, with_options = false)
      new_commands = []

      script_commands = nil
      current_script = ''
      commands.each do |c|
        case c.code
        when 355     # Script
          if script_commands
            new_commands +=
              convert_old_scriptcall(current_script, script_commands,
                                     with_options)
          end
          current_script = c.parameters[0]
          script_commands = [c]
        when 655     # Script body
          current_script += c.parameters[0]
          script_commands <<= c
        else           # Copy all other commands
          if script_commands
            new_commands +=
              convert_old_scriptcall(current_script, script_commands,
                                     with_options)
            script_commands = nil
          end
          new_commands <<= c
        end
      end
      if script_commands
        new_commands += convert_old_scriptcall(current_script, script_commands,
                                               with_options)
      end

      # print new_commands
      new_commands
    end

    # Script calls used by old extraction method
    OLD_DIALOGUE_CALL = /show_dialogue\(('[^']+'|"[^"]+")\)/
    OLD_SCROLLING_CALL = /show_scrolling\(('[^']+'|"[^"]+")\)/

    # Takes a script and either converts it back into a message/scrolling text
    # if it's a script call from the old LFS script - or leaves it as it is if
    # it's an unrelated script call.
    def convert_old_scriptcall(script_content, commands, with_options)
      result = []
      tag = '\dialogue' + (with_options ? '!' : '')

      case script_content
      when OLD_DIALOGUE_CALL
        id = $1[1..-2]

        options = @dialogue_options[id]
        params = ['', 0, 0, 2]
        if options
          params[0] = options[:face_name] if options.key?(:face_name)
          params[1] = options[:face_index] if options.key?(:face_index)
          params[2] = \
            LanguageFileSystem::MSG_BG.index(options[:background]) \
              if options.key?(:background)
          params[3] = \
            LanguageFileSystem::MSG_POS.index(options[:position]) \
              if options.key?(:position)
        end
        result << RPG::EventCommand.new(101, commands[0].indent, params)
        result << RPG::EventCommand.new(401, commands[0].indent,
                                        ["#{tag}[#{id}]"])
      when OLD_SCROLLING_CALL
        id = $1[1..-2]

        options = @dialogue_options[id]
        params = [2, false]
        if options
          params[0] = options[:scroll_speed] if options.key?(:scroll_speed)
          params[1] = options[:scroll_no_fast] == 'true' \
            if options.key?(:scroll_no_fast)
        end
        result << RPG::EventCommand.new(105, commands[0].indent, params)
        result << RPG::EventCommand.new(405, commands[0].indent,
                                        ["#{tag}[#{id}]"])
      end
      result.empty? ? commands : result
    end

    #------------------------------------------------------------------------
    # * Extraction related methods
    #------------------------------------------------------------------------

    # Extracts an event page into dialogue and option hashes.
    # A converted version is of the event page using \dialogue[] tags instead of
    # the actual messages is returned as third result.
    # with_options determines whether the messages should be replaced with the
    # \dialogue![] tag instead of the \dialogue[] tag.
    # All generated IDs will start with the prefix.
    def extract_page(prefix, commands, with_options = false)
      dialogues = {}
      options = {}
      new_commands = []

      i = 1
      current_id = nil
      current_entry = ''
      current_options = {}
      last_code = 0
      commands.each do |c|
        case c.code
        when 101, 105  # Show (Scrolling) Text
          if current_id
            dialogues[current_id] = current_entry.rstrip
            i += 1
          end
          current_id = format("#{prefix}%03d", i)
          current_entry = ''

          current_options = {}
          if c.code == 101
            unless c.parameters[0] == ''
              current_options[:face_name] = c.parameters[0]
              current_options[:face_index] = c.parameters[1]
            end
            current_options[:background] = MSG_BG[c.parameters[2]] \
              unless c.parameters[2] == 0
            current_options[:position] = MSG_POS[c.parameters[3]] \
              unless c.parameters[3] == 2
          else
            current_options[:scroll_speed] = c.parameters[0] \
              unless c.parameters[0] == 2
            current_options[:scroll_no_fast] = "#{c.parameters[1]}" \
              unless c.parameters[1] == false
          end
          new_commands <<= c
        when 401, 405  # Show (Scrolling) Text body
          unless last_code == c.code
            if LanguageFileSystem::DIALOGUE_CODE.match(c.parameters[0])
              # Ignore messages that have already been extracted
              current_id = nil
              new_commands <<= c
              next
            end
            current_id += clean_for_id(c.parameters[0], 15) # create id
            tag = with_options ? 'dialogue!' : 'dialogue'
            new_commands <<= RPG::EventCommand.new(c.code, c.indent,
                                                   ["\\#{tag}[#{current_id}]"])

            options[current_id] = current_options unless current_options.empty?
          end
          current_entry += c.parameters[0] + "\n"
        when 102       # Show Choices
          if current_id
            dialogues[current_id] = current_entry.rstrip
            i += 1
          end
          current_entry = ''
          new_choices = []
          c.parameters[0].each_index do |k|
            if LanguageFileSystem::DIALOGUE_CODE.match(c.parameters[0][k])
              # Ignore choices that have already been extracted
              new_choices <<= c.parameters[0][k]
              next
            end
            current_id = format("#{prefix}%03d%d", i, k)
            current_id += clean_for_id(c.parameters[0][k], 8)
            dialogues[current_id] = c.parameters[0][k].rstrip
            new_choices <<= "\\dialogue[#{current_id}]"
          end
          new_commands <<= RPG::EventCommand.new(102, c.indent,
                                                 [new_choices, c.parameters[1]])
          current_id = nil
          i += 1
        else           # Copy all other commands
          new_commands <<= c
        end
        last_code = c.code
      end
      dialogues[current_id] = current_entry.rstrip if current_id

      [dialogues, options, new_commands]
    end

    # Method used to produce an ID out of a dialogue line.
    # Removes special characters that might cause problems and shortens the line
    # to the specified length.
    def clean_for_id(text, length)
      text.gsub(/[\/\\\.!$\(\)\[\]<>^\|\s]/, '')[0..length - 1]
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

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
# Reads the name and nickname from the database names if it is contains a
# \name[] tag.
#
# Changes:
#   alias: name, nickname
#   overwrite: display_level_up
#==============================================================================
class Game_Actor
  #--------------------------------------------------------------------------
  # * If \name[] tag is contained read it from the database.
  #--------------------------------------------------------------------------
  alias lfs_name name
  def name
    if (m = LanguageFileSystem::NAME_CODE.match(@name))
      result = LanguageFileSystem.database[:names][m[1]]
      return result if result
    end
    actor.name
  end

  #--------------------------------------------------------------------------
  # * If \name[] tag is contained read it from the database.
  #--------------------------------------------------------------------------
  alias lfs_nickname nickname
  def nickname
    if (m = LanguageFileSystem::NAME_CODE.match(@nickname))
      result = LanguageFileSystem.database[:names][m[1]]
      return result if result
    end
    actor.nickname
  end

  # This method is effectively the same as the original just uses the name
  # getter instead of direct access to the @name variable
  alias lfs_display_level_up display_level_up
  def display_level_up(new_skills)
    $game_message.new_page
    $game_message.add(format(Vocab::LevelUp, name, Vocab.level, @level))
    new_skills.each do |skill|
      $game_message.add(format(Vocab::ObtainSkill, skill.name))
    end
  end
end

module RPG
  #============================================================================
  # ** RPG::BaseItem
  #----------------------------------------------------------------------------
  # Reads name, description and note from language file hash instead of using
  # the instance variable if a corresponding entry exists.
  #
  # Changes:
  #   overwrite: getter for @name, @description, @note
  #============================================================================
  class BaseItem
    #------------------------------------------------------------------------
    # * Maps database object class to the corresponding key in the language
    #   file hash to improve polymorphism of the implementation
    #------------------------------------------------------------------------
    SUBCLASS_KEYS = { RPG::Actor => :actors }

    #------------------------------------------------------------------------
    # * Read attribute from language file hash (Metaprogramming ninjutsu :D)
    #------------------------------------------------------------------------
    %w(name description note).each do |var|
      alias_method "lfs_#{var}".to_sym, "#{var}".to_sym
      define_method("#{var}") do
        result = \
          LanguageFileSystem.database[SUBCLASS_KEYS[self.class]][var.to_sym][
            @id]
        result || instance_variable_get("@#{var}")
      end
    end
  end

  #============================================================================
  # ** RPG::Actor
  #----------------------------------------------------------------------------
  # Reads nickname from language file hash instead of using the instance
  # variable if a corresponding entry exists.
  #
  # Changes:
  #   overwrite: getter for @nickname
  #============================================================================
  class Actor < BaseItem
    #------------------------------------------------------------------------
    # * Read attribute from language file hash (Metaprogramming ninjutsu :D)
    #------------------------------------------------------------------------
    %w(nickname).each do |var|
      alias_method "lfs_#{var}".to_sym, "#{var}".to_sym
      define_method("#{var}") do
        result = \
          LanguageFileSystem.database[:actors][var.to_sym][@id]
        result || instance_variable_get("@#{var}")
      end
    end
  end
end
