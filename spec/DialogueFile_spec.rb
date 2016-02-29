# encoding: UTF-8

describe LanguageFileSystem do

  before(:all) do
    open('SimpleFile.rvtext', 'w:UTF-8') do |f|
      f.write(['<<a simple id>>',
               'Blablabla',
               '<<EmptyMessage>>',
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
               '<<bad message>>',
               '<<face: blabla>>',
               '<<special_flag: one>>',
               '<<position: yellow>>',
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
                          ['EmptyMessage', ''],
                          ['MultilineMessage', "I see...\n" \
                           'So this is how you think about it.'])
      end

      it 'produces no error log entries' do
        expect(LanguageFileSystem.error_log).to be_empty
      end
    end

    context 'with a file containing dialogue options' do
      before(:all) do
        LanguageFileSystem.load_rvtext('FileWithOptions.rvtext')
      end

      it 'loads all dialogue texts' do
        expect(LanguageFileSystem.dialogues).to \
          contain_exactly(['good message', 'Good evening sir! ' \
                           'This is a good message!'],
                          ['bad message',
                           'Sorry for the trouble caused by me!'])
      end

      it 'loads the valid dialogue options' do
        expect(LanguageFileSystem.dialogue_options).to \
          contain_exactly(['good message', { face_name: 'Actor2',
                                             face_index: 4,
                                             position: 'top' }],
                          ['bad message', { background: 'dim' }])
      end

      it 'produces an error log with the invalid options' do
        expect(LanguageFileSystem.error_log).to \
          contain_exactly({ file: 'FileWithOptions.rvtext', line: 6,
                            msg: 'Index of face not specified!' },
                          { file: 'FileWithOptions.rvtext', line: 7,
                            msg: "Invalid dialogue option 'special_flag'" },
                          { file: 'FileWithOptions.rvtext', line: 8,
                            msg: "'position' must be 'top', 'middle' " \
                                 "or 'bottom'" })
      end
    end
  end

end
