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
               'Sorry for the caused trouble!'].join("\n") + "\n")
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

  end

end
