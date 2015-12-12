#==============================================================================
# 
# Language File System - Core Script
# Version 1.3.1 - TDD rewrite
# Last Update: March 8th, 2014
# Author: DerTraveler (dertraveler [at] gmail.com)
#
#==============================================================================

$imported = {} if $imported.nil?
$imported[:LanguageFileSystem_Core] = true

module LanguageFileSystem
  
###############################################################################
#
# Do not edit past this point, if you have no idea, what you're doing ;)
#
###############################################################################

  @dialogues = {}
  
  DIALOGUE_CODE = /\\dialogue\[([^\]]+)\]/
  
  def self.dialogues
    {}.replace @dialogues
  end
  
  def self.clear_dialogues
    @dialogues = {}
  end
  
  def self.add_dialogue(id, text)
    @dialogues[id] = text
  end
  
end

#==============================================================================
# ** Game_Message
#------------------------------------------------------------------------------
# Add support for the \dialogues message code.
#
# Changes:
#   alias: all_text
#==============================================================================
class Game_Message

  alias lfs_all_text all_text
  def all_text
    result = lfs_all_text
    if m = LanguageFileSystem::DIALOGUE_CODE.match(result)
      line = LanguageFileSystem::dialogues[m[1]]
      return line + "\n" if line
    end
    result
  end

end

class Game_Interpreter

  #--------------------------------------------------------------------------
  # * Parse for \dialogue[...] and replace choice content if found.
  #--------------------------------------------------------------------------
  alias lfs_setup_choices setup_choices
  def setup_choices(params)
    choices = Array.new(params[0])
    #if LanguageFileSystem::USE_DIALOGUE_FILES
      (0...choices.length).each { |i|
        if m = LanguageFileSystem::DIALOGUE_CODE.match(choices[i])
          line = LanguageFileSystem::dialogues[m[1]]
          choices[i] = line.split("\n")[0] if line
        end
      }
    #end
    lfs_setup_choices([choices] + params[1..-1])
  end
  
end