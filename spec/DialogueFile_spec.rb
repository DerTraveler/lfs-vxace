# encoding: UTF-8

describe LanguageFileSystem do

  before(:all) do
    open('SimpleFile.rvtext', 'w:UTF-8') do |f|
      f.write(['<<a simple id>>',
               'Blablabla',
               '<<MultilineMessage>>',
               'I see...',
               '# This is a comment line',
               'So this is how you think about it.'].join("\n") + "\n")
    end
    open('FileWithOptions.rvtext', 'w:UTF-8') do |f|
      f.write(['<<good message>>',
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
               'Sorry for the trouble caused by me!'].join("\n") + "\n")
    end
  end

  after(:all) do
    File.delete('SimpleFile.rvtext', 'FileWithOptions.rvtext')
  end

  describe '#load_rvtext' do
    context 'with a simple valid file' do
      before(:all) do
        LanguageFileSystem.load_rvtext('SimpleFile.rvtext')
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
        LanguageFileSystem.load_rvtext('FileWithOptions.rvtext')
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

end
