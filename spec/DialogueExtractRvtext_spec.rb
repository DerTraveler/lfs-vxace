# encoding: UTF-8

describe LanguageFileSystem do

  describe '#page_to_rvtext' do
    let(:event_page) do
      [RPG::EventCommand.new(101, 0, ['Actor1', 0, 0, 2]),
       RPG::EventCommand.new(401, 0, ['Hello,']),
       RPG::EventCommand.new(401, 0, ['what are you doing in this lonely ' \
                                      'place?']),
       RPG::EventCommand.new(102, 0, [['(Get angry)', '(Stay silent)'], 2]),
       RPG::EventCommand.new(402, 0, [0, '(Get angry)']),
       RPG::EventCommand.new(101, 1, ['Actor4', 2, 0, 0]),
       RPG::EventCommand.new(401, 1, ["I don't know. You tell me, idiot!"]),
       RPG::EventCommand.new(0, 1, []),   # Branch End
       RPG::EventCommand.new(402, 0, [1, '(Stay silent)']),
       RPG::EventCommand.new(101, 1, ['Actor4', 2, 1, 1]),
       RPG::EventCommand.new(401, 1, ['(Not sure what I should say)']),
       RPG::EventCommand.new(0, 1, []),   # Branch End
       RPG::EventCommand.new(404, 0, []), # Choice Options End
       RPG::EventCommand.new(0, 0, [])]   # Event End
    end

    context 'when not extracting message options' do
      before(:each) do
        @entries, @new_page = LanguageFileSystem.page_to_rvtext('some prefix/',
                                                                event_page)
      end

      it 'creates corresponding rvtext entries' do
        expect(@entries).to include "<<some prefix/001>>\n" \
                                    "Hello,\n" \
                                    'what are you doing in this lonely' \
                                    " place?\n",
                                    "<<some prefix/002-0>>\n" \
                                    "(Get angry)\n" \
                                    "<<some prefix/002-1>>\n" \
                                    "(Stay silent)\n",
                                    "<<some prefix/003>>\n" \
                                    "I don't know. You tell me, idiot!\n",
                                    "<<some prefix/004>>\n" \
                                    "(Not sure what I should say)\n"
      end

      it 'converts dialogue related commands' do
        expect(@new_page[0]).to be event_page[0]
        expect(@new_page[1].code).to be 401
        expect(@new_page[1].indent).to be 0
        expect(@new_page[1].parameters).to eq ['\dialogue[some prefix/001]']
        expect(@new_page[2].code).to be 102
        expect(@new_page[2].indent).to be 0
        expect(@new_page[2].parameters).to eq [['\dialogue[some prefix/002-0]',
                                                '\dialogue[some prefix/002-1]'],
                                               2]
        expect(@new_page[5].code).to be 401
        expect(@new_page[5].indent).to be 1
        expect(@new_page[5].parameters).to eq ['\dialogue[some prefix/003]']
        expect(@new_page[9].code).to be 401
        expect(@new_page[9].indent).to be 1
        expect(@new_page[9].parameters).to eq ['\dialogue[some prefix/004]']
        expect(@new_page.length).to be 13
      end

      it 'leaves unrelated commands untouched' do
        [3, 4, 6, 7, 8, 10, 11, 12].each do |i|
          expect(@new_page[i]).to be event_page[i + 1]
        end
      end
    end

    context 'when extracting message options' do
      before(:each) do
        @entries, @new_page = LanguageFileSystem.page_to_rvtext('some prefix/',
                                                                event_page,
                                                                true)
      end

      it 'converts a page a corresponding rvtext entries' do
        expect(@entries).to include "<<some prefix/001>>\n" \
                                    "<<face: Actor1, 0>>\n" \
                                    "Hello,\n" \
                                    'what are you doing in this lonely' \
                                    " place?\n",
                                    "<<some prefix/002-0>>\n" \
                                    "(Get angry)\n" \
                                    "<<some prefix/002-1>>\n" \
                                    "(Stay silent)\n",
                                    "<<some prefix/003>>\n" \
                                    "<<face: Actor4, 2>>\n" \
                                    "<<position: top>>\n" \
                                    "I don't know. You tell me, idiot!\n",
                                    "<<some prefix/004>>\n" \
                                    "<<face: Actor4, 2>>\n" \
                                    "<<background: dim>>\n" \
                                    "<<position: middle>>\n" \
                                    "(Not sure what I should say)\n"
      end

      it 'converts dialogue related commands' do
        expect(@new_page[0]).to be event_page[0]
        expect(@new_page[1].code).to be 401
        expect(@new_page[1].indent).to be 0
        expect(@new_page[1].parameters).to eq ['\dialogue![some prefix/001]']
        expect(@new_page[2].code).to be 102
        expect(@new_page[2].indent).to be 0
        expect(@new_page[2].parameters).to eq [['\dialogue[some prefix/002-0]',
                                                '\dialogue[some prefix/002-1]'],
                                               2]
        expect(@new_page[5].code).to be 401
        expect(@new_page[5].indent).to be 1
        expect(@new_page[5].parameters).to eq ['\dialogue![some prefix/003]']
        expect(@new_page[9].code).to be 401
        expect(@new_page[9].indent).to be 1
        expect(@new_page[9].parameters).to eq ['\dialogue![some prefix/004]']
        expect(@new_page.length).to be 13
      end

      it 'leaves unrelated commands untouched' do
        [3, 4, 6, 7, 8, 10, 11, 12].each do |i|
          expect(@new_page[i]).to be event_page[i + 1]
        end
      end
    end
  end
end
