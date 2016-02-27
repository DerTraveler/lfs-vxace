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
  end

  after(:all) do
    File.delete('SimpleFile.rvtext')
  end

  describe '#load_rvtext' do
    it 'loads the file into the dialogue hash' do
      LanguageFileSystem.load_rvtext('SimpleFile.rvtext')

      expect(LanguageFileSystem.dialogues).to \
        contain_exactly(['a simple id', 'Blablabla'],
                        ['EmptyMessage', ''],
                        ['MultilineMessage', "I see...\n" \
                         'So this is how you think about it.'])
    end

  end

end
