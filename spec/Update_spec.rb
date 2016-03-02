# encoding: UTF-8

require_relative 'TestPreparation'

describe LanguageFileSystem do

  describe '#versioncheck_dialogue_rvtext' do
    before(:all) do
      @console_output = capture_output do
        LanguageFileSystem.send(:versioncheck_dialogues_rvtext,
                                'OldFile.rvtext')
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
          expect(@updated_lines[i]).to eq(RVTEXT_OLD[i - 1] + "\n")
        end
      end
    end

    it 'creates a backup of the old file' do
      backup_lines = nil
      open('OldFile.rvtext_backup', 'r:UTF-8') do |f|
        backup_lines = f.readlines
      end

      backup_lines.each_index do |i|
        expect(backup_lines[i]).to eq(RVTEXT_OLD[i] + "\n")
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
        LanguageFileSystem.send(:versioncheck_dialogues_rvtext,
                                'OldFile.rvtext')
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

  describe '#update_page' do
    before(:all) do
      LanguageFileSystem.send(:clear_dialogues)
      LanguageFileSystem.send(:add_dialogue, 'InterestingMessage',
                              'Follow your heart!')
      LanguageFileSystem.send(:set_dialogue_options, 'InterestingMessage',
                              position: 'middle', background: 'dim')
      LanguageFileSystem.send(:add_dialogue, 'AnotherOne', "Dude!\nWhat?")
      LanguageFileSystem.send(:set_dialogue_options, 'AnotherOne',
                              face_name: 'Actor3', face_index: 5)
      LanguageFileSystem.send(:add_dialogue, 'Scroller', "Y\nM\nC\nA")
      LanguageFileSystem.send(:add_dialogue, 'BackgroundStory',
                              "His village was pillaged!\nOf course by " \
                              "ravaging orcs!\nWhat else?")
      LanguageFileSystem.send(:set_dialogue_options, 'BackgroundStory',
                              scroll_no_fast: 'true')
    end

    shared_examples 'page update' do |tag|
      it 'converts deprecated script calls back' do
        expect(@new_page[2].code).to be 101
        expect(@new_page[2].indent).to be 0
        expect(@new_page[2].parameters).to eq ['', 0, 1, 1]
        expect(@new_page[3].code).to be 401
        expect(@new_page[3].indent).to be 0
        expect(@new_page[3].parameters).to eq [tag + '[InterestingMessage]']
        expect(@new_page[4].code).to be 101
        expect(@new_page[4].indent).to be 0
        expect(@new_page[4].parameters).to eq ['Actor3', 5, 0, 2]
        expect(@new_page[5].code).to be 401
        expect(@new_page[5].indent).to be 0
        expect(@new_page[5].parameters).to eq [tag + '[AnotherOne]']
        expect(@new_page[8].code).to be 101
        expect(@new_page[8].indent).to be 0
        expect(@new_page[8].parameters).to eq ['Actor3', 5, 0, 2]
        expect(@new_page[9].code).to be 401
        expect(@new_page[9].indent).to be 0
        expect(@new_page[9].parameters).to eq [tag + '[AnotherOne]']
        expect(@new_page[12].code).to be 101
        expect(@new_page[12].indent).to be 0
        expect(@new_page[12].parameters).to eq ['', 0, 1, 1]
        expect(@new_page[13].code).to be 401
        expect(@new_page[13].indent).to be 0
        expect(@new_page[13].parameters).to eq [tag + '[InterestingMessage]']
        expect(@new_page[16].code).to be 105
        expect(@new_page[16].indent).to be 0
        expect(@new_page[16].parameters).to eq [2, false]
        expect(@new_page[17].code).to be 405
        expect(@new_page[17].indent).to be 0
        expect(@new_page[17].parameters).to eq [tag + '[Scroller]']
        expect(@new_page[18].code).to be 105
        expect(@new_page[18].indent).to be 0
        expect(@new_page[18].parameters).to eq [2, true]
        expect(@new_page[19].code).to be 405
        expect(@new_page[19].indent).to be 0
        expect(@new_page[19].parameters).to eq [tag + '[BackgroundStory]']

        expect(@new_page.length).to be 20
      end

      it 'leaves all others untouched' do
        (0..15).each do |i|
          case i
          when 0, 1
            expect(@new_page[i]).to be PAGE_OLD[i]
          when 6, 7
            expect(@new_page[i]).to be PAGE_OLD[i - 1]
          when 10, 11, 14, 15
            expect(@new_page[i]).to be PAGE_OLD[i - 2]
          else
            next
          end
        end
      end
    end

    context 'when updating to not read the options' do
      before(:all) do
        @new_page = LanguageFileSystem.send(:update_page, PAGE_OLD)
      end

      include_examples 'page update', '\dialogue'
    end

    context 'when updating to read the options' do
      before(:all) do
        @new_page = LanguageFileSystem.send(:update_page, PAGE_OLD, true)
      end

      include_examples 'page update', '\dialogue!'
    end
  end
end
