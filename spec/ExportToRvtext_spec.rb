# encoding: UTF-8

require_relative 'TestData'

describe LanguageFileSystem do

  describe '#create_rvtext' do
    before(:all) do
      @dialogues, @options, @new_page =
        LanguageFileSystem.extract_page('some prefix/', EVENT_PAGE)
    end

    context 'when creating without options' do
      it 'creates corresponding rvtext entries' do
        expect(LanguageFileSystem.create_rvtext(@dialogues)).to \
          contain_exactly "<<some prefix/001Witnessadramati>>\n" \
                          "Witness a dramatic meeting\n" \
                          "Of two men\n" \
                          "Two men that should become enemies\n" \
                          "Two men that should become allies\n" \
                          "Let the games begin\n",
                          "<<some prefix/002Hello,>>\n" \
                          "Hello,\n" \
                          "what are you doing in this lonely place?\n",
                          "<<some prefix/0030Getangry>>\n" \
                          "(Get angry)\n",
                          "<<some prefix/0031Staysile>>\n" \
                          "(Stay silent)\n",
                          "<<some prefix/004Idon'tknowYoute>>\n" \
                          "I don't know. You tell me, idiot!\n",
                          "<<some prefix/005NotsurewhatIsho>>\n" \
                          "(Not sure what I should say)\n",
                          "<<some prefix/006Hint:>>\n" \
                          "Hint:\nTry to find another way to approach that" \
                          " person.\n"
      end
    end

    context 'when creating with options' do
      it 'creates corresponding rvtext entries' do
        expect(LanguageFileSystem.create_rvtext(@dialogues, @options)).to \
          contain_exactly "<<some prefix/001Witnessadramati>>\n" \
                          "<<scroll_speed: 4>>\n" \
                          "<<scroll_no_fast: true>>\n" \
                          "Witness a dramatic meeting\n" \
                          "Of two men\n" \
                          "Two men that should become enemies\n" \
                          "Two men that should become allies\n" \
                          "Let the games begin\n",
                          "<<some prefix/002Hello,>>\n" \
                          "<<face: Actor1, 0>>\n" \
                          "Hello,\n" \
                          "what are you doing in this lonely place?\n",
                          "<<some prefix/0030Getangry>>\n" \
                          "(Get angry)\n",
                          "<<some prefix/0031Staysile>>\n" \
                          "(Stay silent)\n",
                          "<<some prefix/004Idon'tknowYoute>>\n" \
                          "<<face: Actor4, 2>>\n" \
                          "<<position: top>>\n" \
                          "I don't know. You tell me, idiot!\n",
                          "<<some prefix/005NotsurewhatIsho>>\n" \
                          "<<face: Actor4, 2>>\n" \
                          "<<background: dim>>\n" \
                          "<<position: middle>>\n" \
                          "(Not sure what I should say)\n",
                          "<<some prefix/006Hint:>>\n" \
                          "Hint:\nTry to find another way to approach that" \
                          " person.\n"
      end
    end
  end

  describe '#export_rvtext' do
    before(:all) do
      @mtimes = Hash[Dir.glob('Data/*.rvdata2').map { |f| [f, File.mtime(f)] }]
      LanguageFileSystem.export_rvtext
    end

    after(:all) do
      File.delete('DialoguesExtracted.rvtext')
    end

    it 'does not change the original files' do
      Dir.glob('Data/*.rvdata2').each do |f|
        expect(File.mtime(f)).to eq @mtimes[f]
      end
    end

    it 'creates an rvtext file containing all dialogues' do
      file_content = nil
      open('DialoguesExtracted.rvtext', 'r:UTF-8') { |f| file_content = f.read }
      expect(file_content).to include \
        "<<M001Mysterio/001Strange/01/001Hello,>>\n" \
        "Hello,\n" \
        "what are you doing in this lonely place?\n",
        "<<M001Mysterio/001Strange/01/002Idon'tknowYoute>>\n" \
        "I don't know. You tell me, idiot!\n",
        "<<M001Mysterio/001Strange/02/001Youarestillhere>>\n" \
        "You are still here?\n",
        "<<M001Mysterio/002Autosta/01/001Thisisthestoryo>>\n" \
        "This is the story of a man\n" \
        "who did not know\n" \
        "what was good for him.\n" \
        "He set out to fulfill his\n" \
        "selfish desires.\n" \
        "Witness the dramatic events unfold...\n",
        "<<M001Mysterio/003Telepor/01/001ShouldIreallyen>>\n" \
        "(Should I really enter this strange\n" \
        " looking portal?)\n",
        "<<M001Mysterio/003Telepor/01/0020Surethin>>\n" \
        "Sure thing!\n",
        "<<M001Mysterio/003Telepor/01/0021Wwaitamo>>\n" \
        "W.. wait a moment\n",
        "<<M001Mysterio/003Telepor/01/003Maybeanothertim>>\n" \
        "Maybe another time...\n",
        "<<M002EndlessM/001Flame/01/001Whatisthis?>>\n" \
        "What\\. is\\. this?\n",
        "<<C004SpecialScript/001Thiswillneverbe>>\n" \
        "This will never be triggered! Sad isn't it?\n",
        "<<B013Orc*3/01/001I'mgunnaeat,huu>>\n" \
        "I'm gunna eat, huuuuuuman!\n"
    end

  end
end
