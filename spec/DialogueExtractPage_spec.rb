# encoding: UTF-8

require_relative 'TestData'

describe LanguageFileSystem do

  describe '#extract_page' do
    shared_examples 'page extraction' do |tag|

      it 'extracts all of the dialogues' do
        expect(@dialogues).to \
          contain_exactly(['some prefix/001Witnessadramati',
                           "Witness a dramatic meeting\nOf two men\n" \
                           "Two men that should become enemies\n" \
                           "Two men that should become allies\n" \
                           'Let the games begin'],
                          ['some prefix/002Hello,',
                           "Hello,\nwhat are you doing in this lonely place?"],
                          ['some prefix/0030Getangry', '(Get angry)'],
                          ['some prefix/0031Staysile', '(Stay silent)'],
                          ["some prefix/004Idon'tknowYoute",
                           "I don't know. You tell me, idiot!"],
                          ['some prefix/005NotsurewhatIsho',
                           '(Not sure what I should say)'],
                          ['some prefix/006Hint:',
                           "Hint:\nTry to find another way to approach that" \
                           ' person.'])
      end

      it 'extracts all of the options' do
        expect(@options).to \
          contain_exactly(['some prefix/001Witnessadramati',
                           { scroll_speed: 4, scroll_no_fast: 'true' }],
                          ['some prefix/002Hello,',
                           { face_name: 'Actor1', face_index: 0 }],
                          ["some prefix/004Idon'tknowYoute",
                           { face_name: 'Actor4', face_index: 2,
                             position: 'top' }],
                          ['some prefix/005NotsurewhatIsho',
                           { face_name: 'Actor4', face_index: 2,
                             position: 'middle', background: 'dim' }])
      end

      it 'converts dialogue related commands' do
        expect(@new_page[1].code).to be 405
        expect(@new_page[1].indent).to be 0
        expect(@new_page[1].parameters).to \
          eq [tag + '[some prefix/001Witnessadramati]']
        expect(@new_page[3].code).to be 401
        expect(@new_page[3].indent).to be 0
        expect(@new_page[3].parameters).to \
          eq [tag + '[some prefix/002Hello,]']
        expect(@new_page[4].code).to be 102
        expect(@new_page[4].indent).to be 0
        expect(@new_page[4].parameters).to \
          eq [['\dialogue[some prefix/0030Getangry]',
               '\dialogue[some prefix/0031Staysile]'], 2]
        expect(@new_page[7].code).to be 401
        expect(@new_page[7].indent).to be 1
        expect(@new_page[7].parameters).to \
          eq [tag + "[some prefix/004Idon'tknowYoute]"]
        expect(@new_page[11].code).to be 401
        expect(@new_page[11].indent).to be 1
        expect(@new_page[11].parameters).to \
          eq [tag + '[some prefix/005NotsurewhatIsho]']
        expect(@new_page[15].code).to be 401
        expect(@new_page[15].indent).to be 0
        expect(@new_page[15].parameters).to \
          eq [tag + '[some prefix/006Hint:]']
        expect(@new_page.length).to be 17
      end

      it 'leaves unrelated commands untouched' do
        expect(@new_page[0]).to be EVENT_PAGE[0]
        expect(@new_page[2]).to be EVENT_PAGE[6]
        [5, 6, 8, 9, 10, 12, 13, 14].each do |i|
          expect(@new_page[i]).to be EVENT_PAGE[i + 5]
        end
        expect(@new_page[16]).to be EVENT_PAGE[22]
      end
    end

    context 'when extracting for the first time' do
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

    context 'when extracting already partly extracted events' do
      before(:all) do
        @dialogues, @options, @new_page =
          LanguageFileSystem.extract_page('some prefix/', EXTRACTED_PAGE)
      end

      it 'extracts the new dialogues' do
        expect(@dialogues).to \
          contain_exactly(['some prefix/0012Glareath', '(Glare at him)'],
                          ['some prefix/002Whoa,manCalmdow',
                           'Whoa, man! Calm down!'])
      end

      it 'extracts the new options' do
        expect(@options).to \
          contain_exactly(['some prefix/002Whoa,manCalmdow',
                           { face_name: 'Actor1', face_index: 0 }])
      end

      it 'converts the not yet extracted commands' do
        expect(@new_page[2].code).to be 102
        expect(@new_page[2].indent).to be 0
        expect(@new_page[2].parameters).to \
          eq [['\dialogue[some prefix/002-0:Getangr]',
               '\dialogue[some prefix/002-1:Staysil]',
               '\dialogue[some prefix/0012Glareath]'], 2]
        expect(@new_page[13].code).to be 401
        expect(@new_page[13].indent).to be 1
        expect(@new_page[13].parameters).to \
          eq ['\\dialogue[some prefix/002Whoa,manCalmdow]']
        expect(@new_page.length).to be 17
      end

      it 'leaves all others untouched' do
        (0..15).each do |i|
          case i
          when 2, 13
            next
          else
            expect(@new_page[i]).to be EXTRACTED_PAGE[i]
          end
        end
      end

    end
  end
end
