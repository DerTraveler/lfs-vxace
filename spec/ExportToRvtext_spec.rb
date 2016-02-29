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
          contain_exactly "<<some prefix/001:Hello,>>\n" \
                          "Hello,\n" \
                          "what are you doing in this lonely place?\n",
                          "<<some prefix/002-0:Getangr>>\n" \
                          "(Get angry)\n",
                          "<<some prefix/002-1:Staysil>>\n" \
                          "(Stay silent)\n",
                          "<<some prefix/003:Idon'tknowYoutellme,>>\n" \
                          "I don't know. You tell me, idiot!\n",
                          "<<some prefix/004:NotsurewhatIshouldsa>>\n" \
                          "(Not sure what I should say)\n",
                          "<<some prefix/005:Hint:>>\n" \
                          "Hint:\nTry to find another way to approach that" \
                          " person.\n"
      end
    end

    context 'when creating with options' do
      it 'creates corresponding rvtext entries' do
        expect(LanguageFileSystem.create_rvtext(@dialogues, @options)).to \
          contain_exactly "<<some prefix/001:Hello,>>\n" \
                          "<<face: Actor1, 0>>\n" \
                          "Hello,\n" \
                          "what are you doing in this lonely place?\n",
                          "<<some prefix/002-0:Getangr>>\n" \
                          "(Get angry)\n",
                          "<<some prefix/002-1:Staysil>>\n" \
                          "(Stay silent)\n",
                          "<<some prefix/003:Idon'tknowYoutellme,>>\n" \
                          "<<face: Actor4, 2>>\n" \
                          "<<position: top>>\n" \
                          "I don't know. You tell me, idiot!\n",
                          "<<some prefix/004:NotsurewhatIshouldsa>>\n" \
                          "<<face: Actor4, 2>>\n" \
                          "<<background: dim>>\n" \
                          "<<position: middle>>\n" \
                          "(Not sure what I should say)\n",
                          "<<some prefix/005:Hint:>>\n" \
                          "Hint:\nTry to find another way to approach that" \
                          " person.\n"
      end
    end
  end
end
