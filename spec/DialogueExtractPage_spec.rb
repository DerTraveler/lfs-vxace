# encoding: UTF-8

require_relative 'TestData'

describe LanguageFileSystem do

  describe '#extract_page' do
    shared_examples 'page extraction' do |tag|

      it 'extracts all of the dialogues' do
        expect(@dialogues).to \
          contain_exactly(['some prefix/001:Hello,',
                           "Hello,\nwhat are you doing in this lonely place?"],
                          ['some prefix/002-0:Getangr', '(Get angry)'],
                          ['some prefix/002-1:Staysil', '(Stay silent)'],
                          ["some prefix/003:Idon'tknowYoutellme,",
                           "I don't know. You tell me, idiot!"],
                          ['some prefix/004:NotsurewhatIshouldsa',
                           '(Not sure what I should say)'])
      end

      it 'extracts all of the options' do
        expect(@options).to \
          contain_exactly(['some prefix/001:Hello,',
                           { face_name: 'Actor1', face_index: 0 }],
                          ["some prefix/003:Idon'tknowYoutellme,",
                           { face_name: 'Actor4', face_index: 2,
                             position: 'top' }],
                          ['some prefix/004:NotsurewhatIshouldsa',
                           { face_name: 'Actor4', face_index: 2,
                             position: 'middle', background: 'dim' }])
      end

      it 'converts dialogue related commands' do
        expect(@new_page[1].code).to be 401
        expect(@new_page[1].indent).to be 0
        expect(@new_page[1].parameters).to \
          eq [tag + '[some prefix/001:Hello,]']
        expect(@new_page[2].code).to be 102
        expect(@new_page[2].indent).to be 0
        expect(@new_page[2].parameters).to \
          eq [['\dialogue[some prefix/002-0:Getangr]',
               '\dialogue[some prefix/002-1:Staysil]'], 2]
        expect(@new_page[5].code).to be 401
        expect(@new_page[5].indent).to be 1
        expect(@new_page[5].parameters).to \
          eq [tag + "[some prefix/003:Idon'tknowYoutellme,]"]
        expect(@new_page[9].code).to be 401
        expect(@new_page[9].indent).to be 1
        expect(@new_page[9].parameters).to \
          eq [tag + '[some prefix/004:NotsurewhatIshouldsa]']
        expect(@new_page.length).to be 13
      end

      it 'leaves unrelated commands untouched' do
        expect(@new_page[0]).to be EVENT_PAGE[0]
        [3, 4, 6, 7, 8, 10, 11, 12].each do |i|
          expect(@new_page[i]).to be EVENT_PAGE[i + 1]
        end
      end
    end

    context 'when not extracting message options' do
      before(:all) do
        @dialogues, @options, @new_page =
          LanguageFileSystem.extract_page('some prefix/', EVENT_PAGE)
      end

      include_examples 'page extraction', '\dialogue'
    end

    context 'when extracting message options' do
      before(:all) do
        @dialogues, @options, @new_page =
          LanguageFileSystem.extract_page('some prefix/', EVENT_PAGE, true)
      end

      include_examples 'page extraction', '\dialogue!'
    end
  end
end
