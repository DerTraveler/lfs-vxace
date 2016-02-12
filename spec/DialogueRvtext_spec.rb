# encoding: UTF-8

require_relative 'HelperMethods'

describe LanguageFileSystem do

  SIMPLE_FILE = ['<<a simple id>>',
                 'Blablabla',
                 '<<MultilineMessage>>',
                 'I see...',
                 '# This is a comment line',
                 'So this is how you think about it.']

  FILE_WITH_OPTIONS = ['<<good message>>',
                       '<<face: Actor2, 4>>',
                       '<<position: top>>',
                       'Good evening sir! This is a good message!',
                       '<<empty bad message>>',
                       '<<face: MrX, 12>>',
                       '<<scroll_speed: -12>>',
                       '<<bad message>>',
                       '<<face: blabla>>',
                       '<<special_flag: one>>',
                       '<<position: yellow>>',
                       '<<scroll_no_fast: Excalibur>>',
                       '<<background: dim>>',
                       'Sorry for the trouble caused by me!']

  OLD_FILE = ['<<OldScrollMessage>>',
              '<<no_fast>>',
              'Take it easy!',
              '<<HelloThere>>',
              '<<background: transparent>>',
              'What was that???']

  FILES = { 'SimpleFile.rvtext' => SIMPLE_FILE,
            'FileWithOptions.rvtext' => FILE_WITH_OPTIONS,
            'OldFile.rvtext' => OLD_FILE }

  before(:all) do
    FILES.each do |filename, content|
      open(filename, 'w:UTF-8') do |f|
        f.write(content.join("\n") + "\n")
      end
    end
  end

  after(:all) do
    File.delete(*FILES.keys)
  end

  describe '#load_dialogues_rvtext' do
    context 'with a simple valid file' do
      before(:all) do
        LanguageFileSystem.load_dialogues_rvtext('SimpleFile.rvtext')
      end

      it 'loads the file into the dialogue hash' do
        expect(LanguageFileSystem.dialogues).to \
          contain_exactly(['a simple id', 'Blablabla'],
                          ['MultilineMessage', "I see...\n" \
                           'So this is how you think about it.'])
      end

      it 'produces no log entries' do
        expect(LanguageFileSystem.log).to be_empty
      end
    end

    context 'with a file containing dialogue options' do
      before(:all) do
        LanguageFileSystem.load_dialogues_rvtext('FileWithOptions.rvtext')
      end

      it 'loads all dialogue texts, also empty ones' do
        expect(LanguageFileSystem.dialogues).to \
          contain_exactly(['good message', 'Good evening sir! ' \
                           'This is a good message!'],
                          ['empty bad message', ''],
                          ['bad message',
                           'Sorry for the trouble caused by me!'])
      end

      it 'loads the valid dialogue options' do
        expect(LanguageFileSystem.dialogue_options).to \
          contain_exactly(['good message', { face_name: 'Actor2',
                                             face_index: 4,
                                             position: 'top' }],
                          ['empty bad message', {}],
                          ['bad message', { background: 'dim' }])
      end

      it 'produces errors for the invalid options' do
        expect(LanguageFileSystem.log).to \
          include({ file: 'FileWithOptions.rvtext', line: 6, type: :error,
                    msg: 'Index of face must be between 0 and 7!' },
                  { file: 'FileWithOptions.rvtext', line: 7, type: :error,
                    msg: "'scroll_speed' must be between 1 and 8!" },
                  { file: 'FileWithOptions.rvtext', line: 9, type: :error,
                    msg: 'Index of face not specified!' },
                  { file: 'FileWithOptions.rvtext', line: 10, type: :error,
                    msg: "Invalid dialogue option 'special_flag'" },
                  { file: 'FileWithOptions.rvtext', line: 11, type: :error,
                    msg: "'position' must be 'top', 'middle' or 'bottom'" },
                  { file: 'FileWithOptions.rvtext', line: 12, type: :error,
                    msg: "'scroll_no_fast' must be 'true' or 'false'" })
      end

      it 'produces an warning for the empty message' do
        expect(LanguageFileSystem.log).to \
          include(file: 'FileWithOptions.rvtext', line: 5, type: :warning,
                  msg: "Message with id 'empty bad message' is empty!")
      end
    end
  end

  describe '#versioncheck_dialogue_rvtext' do
    before(:all) do
      @console_output = capture_output do
        LanguageFileSystem.versioncheck_dialogues_rvtext('OldFile.rvtext')
      end

      open('OldFile.rvtext', 'r:UTF-8') do |f|
        @updated_lines = f.readlines
      end
    end

    after(:all) do
      File.delete('OldFile.rvtext_backup')
    end

    it 'adds the current version header' do
      expect(@updated_lines[0]).to \
        eq "# LFS DIALOGUES VERSION #{LanguageFileSystem::CURRENT_VERSION}\n"
    end

    it 'updates the file contents to the current version (20)' do
      @updated_lines.each_index do |i|
        case i
        when 0
          next
        when 2
          expect(@updated_lines[i]).to eq "<<scroll_fast: true>>\n"
        else
          expect(@updated_lines[i]).to eq(OLD_FILE[i - 1] + "\n")
        end
      end
    end

    it 'creates a backup of the old file' do
      backup_lines = nil
      open('OldFile.rvtext_backup', 'r:UTF-8') do |f|
        backup_lines = f.readlines
      end

      backup_lines.each_index do |i|
        expect(backup_lines[i]).to eq(OLD_FILE[i] + "\n")
      end
    end

    it 'shows a messagebox to notify the user' do
      expect(@console_output).to \
        eq "MSGBOX:Dialogues have been updated to current file format.\n" \
           "The original file was renamed to 'OldFile.rvtext_backup'"
    end

    it 'leaves up-to-date files as they are' do
      # Try to update a second time
      console_output = capture_output do
        LanguageFileSystem.versioncheck_dialogues_rvtext('OldFile.rvtext')
      end
      uptodate_lines = nil
      open('OldFile.rvtext', 'r:UTF-8') do |f|
        uptodate_lines = f.readlines
      end

      # No changes
      uptodate_lines.each_index do |i|
        expect(uptodate_lines[i]).to eq @updated_lines[i]
      end

      # No message box
      expect(console_output).to be_empty
    end
  end
end
