# Language File System

*IMPORTANT NOTE:*<br>
This README is still mostly the old version from LFS Version 1.3. It does not
yet fully reflect the rewritten features.

## Contents:

1. Description
2. File formats
  1. Dialogues.rvtext
    1. Examples
    2. How to include the text
    3. Additional Details
  2. DatabaseText.rvtext
    1. Examples
    2. Changing custom scripts
3. More Features
    1. Changing the names of actors
    2. Changing the language
    3. Encrypting your text files
    4. Extracting all your text content
    5. Language-dependent pictures
4. Common issues
5. Changelog
6. Terms of use

## 1. Description:
This script enables you to load any of the game's text content from external
files. This includes messages, choices, and any database text.
With this script it is much easier to manage your in-game text content, since
all of your dialogue is at one central place instead of being spread over
hundreds and thousands of events.
Another major use is the ability to translate your game, without the need to
create a new project for each language and edit every field in the database.

## 2. File formats
This script uses two text files with a special (but very simple) format. The
structure of those files is described in this section. Language names can be
defined in the option section below.

NOTE:<br>
The file names in the section headers are used in case you only use one
language file in your game. If you use more than one language file, the
names will have the language name as suffix.

Example:<br>
Suppose, in the options below you have defined `:German` and `:English` as
languages for your game. Thus the filenames would be DialoguesGerman.rvtext
and DialoguesEnglish.rvtxt and respectively DatabaseTextGerman.rvtext and
DatabaseTextEnglish.rvtext.

### Dialogues.rvtext
In this file you can define text blocks that can be used in "Show Text",
"Show Choices" and "Show Scrolling Text" commands.

NOTE:<br>
Please don't edit the first line starting with `#`, since it contains version
information for the script.

A text block is defined in this way:

    <<[Text ID]>>
    <<[Option Tag 1]>>
    <<[Option Tag 2]>>
    ...
    [Your Text]

[Text ID]<br>
This should be an unique string that will be used in the RPG Maker to load
your text block.

[Your Text]<br>
This is the text that will be shown in the message or choice. This can of
course cover multiple lines. Everything until the next `<<...>>` tag will
belong to that [Text ID]. But excessive empty lines at the end will be
stripped away.

[Option Tag]<br>
Here you can specify message options like face, position and background.
This information is used, if you call the message via script call or if you
use the text viewer add-on to display the message.
If you just use the message code in a normal "Show Text..." it will be
ignored.

#####Available tags for messages:
###### \<\<face:[Filename],[Index]\>\>
[Filename]<br>
The name of the Faceset file, eg. Actor1

[Index]<br>
The index in the Faceset of the face that should be used.<br>
Ranges from 0-7.

<br>If you omit this tag, the message won't have a face.

###### \<\<position:[Place]\>\>
[Place]<br>
Specifies the position of the message window.<br>
Can be either: top, middle or bottom (default).

###### \<\<background:[Style]\>\>
[Style]<br>
Specifies the style of the message window.<br>
Can be: normal (default), dim or transparent.

##### Available tags for scrolling texts:
###### \<\<scroll_speed:[Speed]\>\>
[Speed]<br>
Scrolling speed of the message. Ranges from 1-8

###### \<\<scroll_no_fast:true/false\>\>
If true then fast forwarding by pressing the OK button is disabled.

#### Examples
Just to get an idea how the file content actually will look like. See the demo
for more examples.

---
    <<Introduction>>
    <<scroll_speed: 4>>
    Once upon a time there was a kingdom which was
    rules by a wise king...
    Blablablablabla...

    <<Soldier Greeting>>
    <<face: People4, 6>>
    \C[6]Soldier:\C[0]
    Greetings! Don't make any trouble!

    <<Find Dragonball>>
    <<position: middle>>
    Congratulations!
    You have found one of the seven dragonballs!

    <<Evil Sorcerer Speech>>
    <<position: middle>>
    <<background: transparent>>
    So you finally made it into my lair?
    Prepare to die a slow and horrible death!
    HAHAHAHAHAHAHAHAHA!
---

#### How to include the text

##### Messages:
You enter the following message code into a "Show Text..."-command:

    \dialogue[Text ID]        (NOTE: You have to enter the [] characters!)

    or

    \dialogue![Text ID]

If the Text ID exists, the content of the message will be replaced with
your text block.

When you use the normal `dialogue` tag, Option Tag information from your
text file will be ignored and instead the settings of your event command
will be used. If you however use the tag with the exclamation mark
(`\dialogue![...]`) then the Option Tag information from the file will be
used.


##### Scrolling Text:

Same as Messages just that you enter the tag into the text field of the
"Show Scrolling Text..." command.

##### Choices:

Just enter the \dialogue[...] message code instead of a choice option.

Please note that a choice option has a maximal length of 50 characters.
So you Text IDs for choices can be at most 39 characters long (50 minus
11 for the \dialogue[])

#### Additional details

* If you define a multiline string for a choice option, everything after the
  first line will be ignored.

* Your Dialogue File should be always encoded in UTF-8 (extracted files will be
  automatically in UTF-8).

### DatabaseText.rvtext

In this file you can define literally every text property, that can be entered
into the database of the RPG Maker.
Any property not defined in this file will just use the value from the
database.

NOTE:<br>
Don't use multiline text properties, when the original field in RPG
Maker didn't allow to enter several lines of text. Otherwise these line
breaks will be shown as strange symbols in-game.

The format of this file is similar to the Dialogue textfiles but instead of a
freely assigned unique ID, you use predefined IDs for every element.

\<\<[group]/[id]/[variable]\>\>
This format is used for all the base item classes.

[group]<br>
Specifies the group of database objects.

Available groups are
    - actors       - classes      - skills
    - items        - weapons      - enemies
    - states       - maps

[id]<br>
The id of your object in the RPG Maker database.

[variable]<br>
The name of the text property you want to change.

Following variables are accessible for every group except maps. They
should be self-explanatory:
    - name         - description  - note

In addition to these, following groups have additional variables.
Unless specified otherwise, they should be self-explanatory:

    actors:
      - nickname

    classes
      - learnings_note:[id] (note text field of the learned skill at position
                            [id])

    skills
      - message1     - message2   (two-lined message when using)

    states
      - message1    (message when an actor falls into the state)
      - message2    (message when an enemy falls into the state)
      - message3    (message when somebody retains the state)
      - message4    (message when an actor loses the state)

The group maps has following variables:
      - display_name  (The name that is displayed when entering the map)
      - note

Following predefined IDs change the properties in the System and Terms tab of
the database.

    <<system/game_title>>
    The game title that is printed on title screen.

    <<system/currency_unit>>
    The name of the in-game currency.

    <<types/elements:[id]>>
    The name of the element with the given [id].

    <<types/skill_types/[id]>>
    The name of the skill type with the given [id].

    <<types/weapon_types/[id]>>
    The name of the weapon type with the given [id].

    <<types/armor_types/[id]>>
    The name of the armor type with the given [id].

    <<terms/basic/[id]>>
    See RPG::System::Term in the RPG Maker help file for details.

    <<terms/params/[id]>>
    See RPG::System::Term in the RPG Maker help file for details.

    <<terms/etypes/[id]>>
    See RPG::System::Term in the RPG Maker help file for details.

    <<terms/commands/[id]>>
    See RPG::System::Term in the RPG Maker help file for details.

Finally you can also change the values of the constants in the Vocab-Script
with following tag.

    <<constants/Vocab/[constant name]>>

##### Examples

Just to get an idea how the file content actually will look like. See the demo
for more examples.

---

    <<actors/3/name>>
    Bob

    <<states/11/message4>>
     is no longer confused. (The first character is a space)

    <<classes/1/learnings_note/3>>
    <special learning notetag: some-property>

    <<constants/Vocab/ShopBuy>>
    Buy some stuff

---

### Changing custom scripts

With the DatabaseText.rvtext you can change custom scripts in three ways:

1. Changing module constants

  This works just exactly the same way like changing the constants in the
  Vocab module of the RPG Maker VX Ace.
  The ID has following format:

      <<constants/[module name]/[constant name]>>

  EXAMPLE:

  Let's assume you are using Yanfly's Battle Engine Ace and want to
  translate the constant YEA::BATTLE::HELP_TEXT_ALL_FOES.
  The corresponding entry in the DatabaseText.rvtext looks like this:

      <<constants/YEA::BATTLE/HELP_TEXT_ALL_FOES>>
      All foes, yeah!

2. Changing variable assignments

  The method described above only works for constants. But there are also
  many custom script options that are not saved in constants, either because
  you can change them at runtime, or because many similar options are saved
  in a hash. Any string variable (and only strings) you can assign via the
   = operator can be changed with this method. This should become clearer
  when you look at the example.

  EXAMPLE:

  We're in YEA's Battle Engine again. This time we want to change the popup
  that appears when someone misses with their attack.

  The entry in the DatabaseText.rvtext looks like this:

      <<variables/YEA::BATTLE::POPUP_SETTINGS[:missed]>>
      NOPE!


3. Running arbitrary Ruby code

  If any of the translations you need to do is not possible with the change
  of a variable or constant, but perhaps only with a method call, you can
  also run arbitrary Ruby code and replace some part of the code with the
  value from the language file. The position that is to be translated is
  marked by %s. %s will be replaced with your value.

  EXAMPLE:

  Let's imagine, you have English and Japanese translations of your game,
  but the Japanese characters in your custom menu script are hard to read
  when your font style is bold. For some reason the creator of the menu
  script has only provided a set_font_style method to change the font style
  of the menu.

  The entry in the Japanese DatabaseText.rvtext would look like this:

      <<eval/CustomMenuScript::set_font_style(%s)>>
      :normal

  Whereas the entry in the English file would be this one:

      <<eval/CustomMenuScript::set_font_style(%s)>>
      :bold

  NOTE:<br>
  If your script call needs any quotation marks you have to insert
  them either in the ID or in the value. They are not added
  automatically.

## 3. More Features

### Changing the names of actors

If you use the "Change Name..." or "Change Nickname..." event command to
change the name of one of the actors, you can also define those names in the
DatabaseText.rvtxt file and use them with the \name message code.

EXAMPLE:

Let's suppose you want to change the name of Gandalf to "Gandalf, the White"
or "Gandalf, der Weiße" depending on the language of your game.

In your DatabaseTextEnglish.rvtext and DatabaseTextGerman.rvtext you create
an entry that looks like this:

    English:                               German:
    <<names/gandalf_newname>>              <<names/gandalf_newname>>
    Gandalf, the White                     Gandalf, der Weiße

Afterwards you can just use the normal "Change name..." event command, but
instead of your name you just enter "\name[gandalf_newname]" into the text
field. And the name will be changed according to your language.

### Changing the language

If you want to change the language in-game just call following function via
script call:

  LanguageFileSystem::set_language(language_name)

The change will be effective until the language is changed again even when
the game is closed.
The last active language will be saved in the "Game.ini" in the project
directory. The entry is called "Language". If there is no entry the language
specified in DEFAULT_LANGUAGE will be used.

The current language can be retrieved with a script call to:

  LanguageFileSystem::language

### Encrypting your text files

If you want to distribute your game, most probably you don't want anyone to
spy on your game's texts.
In order to prevent this you can encrypt your text files into RPG Maker style
rvdata2-files in your Data-directory. If you create an compressed game
archive after that, these files will also be included and will be rendered
unreadable for your players consequently.

When you want to distribute your game, just call following script command
while the game is running (e.g. with by a temporary created debug event).

  LanguageFileSystem::encrypt

After that the encrypted files were created in the Data-directory. Now you can
undo all the changes made to the game to call the command and move the .rvtext
files out of your project directory (I guess you shouldn't delete them ;) -
we don't want your hard translation work to be wasted, right?) to some other
place.
The last thing you have to do before compressing your game, is setting the
ENABLE_ENCRYPTION option to true, so that the game won't search for the
.rvtext files anymore and uses the encrypted data files instead. Of course you
should playtest the game at least once more to make sure that the encryption
and the related changes were successful.

### Extracting all your text content

If you already have a lot of in-game text content, this script allows you to
extract ALL of this content (all messages, choices, scrolling texts, name
changes in all of your map and common events as well as every text field in
in the database) with one script call.

  LanguageFileSystem::extract_all_data

This creates a subfolder in your project directory called "Extracted". In this
folder contains both the "Dialogues.rvtext" and the "DatabaseText.rvtext"
files with all of your text content. In addition to that there is a copy of
the Data-Folder of your project, which includes an updated version of your
maps and common events, that use all the corresponding script calls.

IMPORTANT:<br>
Please make a backup copy of your original Data-Folder in a safe
place in case you want to revert the conversion later!

After you hopefully made this backup copy, you should close the RPG Maker VX
Ace and move the contents of the "Extracted/Data" folder into your original
data folder. Next time you open your project in the RPG Maker, every event
should now use script alls instead of messages and have replaced every
choice and name change text with the corresponding message codes.

Don't forget to replace or merge the "DatabaseText.rvtext" and
"Dialogues.rvtext" in your project folder with the ones from the
Extracted-Folder, so the text content can be found by the script.

### Language-dependent pictures

If you use pictures that show text, like interface elements for custom menus
or screenshots for tutorials, you might want to have translated versions for
each of your languages.

To make a picture multilingual, you need to create a translated copy for each
language and rename it, so it ends with the respective language name. The
names must be written exactly as specified in the LANGUAGES option (though
without the : character).
The picture you use in the RPG Make must be the version of the default
language specified in the DEFAULT_LANGUAGE option.

NOTE:<br>
This also works for titlescreens, battle backgrounds and every other
kind of bitmap.

EXAMPLE:

You have a picture for the world map in English and in Japanese. So you
should create two files named somehow like that:

    WorldMap English.png
    WorldMap Japanese.png

And in the RPG Maker you always use the "WorldMap English.png" since English
is your default language.

## 4. Common issues

#### Your script doesn't work with Custom Message System "X"

Fix:
If the message system in question reuses the methods of the standard RPG Maker
message system, there is a good chance that it can still work.
Just paste my script ABOVE the message system script and try out again if that
helped.

Known scripts where this fix is necessary:
* Advanced Text System: Choice Options

## 5. Changelog

    1.3:
    - Bugfix: Encryption of data now really encrypts each of the languages
              into the correct file.
    - Bugfix: Encryption of the up-to-date language files now also works,
              when the ENABLE_ENCRYPTION flag is set.
    - Fixed the Game.ini writing method that produced excessive newlines
    - Updated the file format for the DatabaseText.rvdata. It now uses '/'
      as separator and puts constants in its own group. Old files are updated
      automatically
    - New Feature: Added the possibility of language-dependent variable
                   assignments and (for Ruby-experienced advanced users) to
                   evaluate any Ruby command with the %s placeholder
    - New Feature: Language-dependent pictures
    1.2:
    - Added support for in-game name changes
    - Added support for class skill learning notes
    - Major overhaul of the documentation
    - New Feature: Added the possibility to define all message options in the
                   language file and thus to call the whole message via script
                   call. This works both for normal messages as well as for
                   scrolling texts.
    - New Feature: Now you can extract ALL of your in-game text into the
                   corresponding language files with one script call. At the
                   same time alternative versions of all your maps and common
                   events are created that use these text files, so you don't
                   have to change all your events manually.
    1.1:
    - Rewriting of some logic to increase compatibility
    - New Feature: Last used language is now saved in Game.ini instead of a
                   separate file
    - Bugfix: USE_DIALOGUE_FILES and USE_DATABASE_FILES now also work
              when setting a new language
    - Bugfix: Nonexisting text IDs in choice options are now ignored (just as
              with normal messages)
    - Bugfix: Accessing an base item that isn't included in the database text
              file now doesn't result in a crash anymore.
    - Bugfix: Included some Exception handling for erroneous database text
              file IDs

## 6. Terms of use:
* Free to use in any non-commercial project.
  For use in commercial projects please mail me.
* Please mail me if you find bugs so I can fix them.
* If you have feature requests, please also mail me, but I can't guarantee
  that I will add every requested feature.
* Credit DerTraveler in your project and please notify me if you publish a
  game that uses one of my scripts.
