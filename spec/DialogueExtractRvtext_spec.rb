# encoding: UTF-8

describe LanguageFileSystem do

  describe '#page_to_rvtext' do
    let(:page_1) do
      [RPG::EventCommand.new(101, 0, ['Actor1', 0, 0, 2]),
       RPG::EventCommand.new(401, 0, ['Hello,']),
       RPG::EventCommand.new(401, 0, ['what are you doing in this lonely ' \
                                      'place?']),
       RPG::EventCommand.new(101, 0, ['Actor4', 0, 0, 2]),
       RPG::EventCommand.new(401, 0, ["I don't know. You tell me!"])]
    end

    context 'when not extracting message options' do
      before(:each) do
        @entries, @new_page = LanguageFileSystem.page_to_rvtext('some prefix/',
                                                                page_1)
      end

      it 'creates corresponding rvtext entries' do
        expect(@entries).to include "<<some prefix/001>>\nHello,\n" \
                                    'what are you doing in this lonely ' \
                                    "place?\n",
                                    "<<some prefix/002>>\n" \
                                    "I don't know. You tell me!\n"
      end

      it 'returns a converted command list' do
        expect(@new_page[0]).to be page_1[0]
        expect(@new_page[1].code).to be 401
        expect(@new_page[1].parameters).to eq ['\dialogue[some prefix/001]']
        expect(@new_page[2]).to be page_1[3]
        expect(@new_page[3].code).to be 401
        expect(@new_page[3].parameters).to eq ['\dialogue[some prefix/002]']

        expect(@new_page.length).to be 4
      end
    end

    context 'when extracting message options' do
      before(:each) do
        @entries, @new_page = LanguageFileSystem.page_to_rvtext('some prefix/',
                                                                page_1,
                                                                true)
      end

      it 'converts a page a corresponding rvtext entries' do
        expect(@entries).to include "<<some prefix/001>>\n" \
                                    "<<face: Actor1, 0>>\nHello,\n" \
                                    'what are you doing in this lonely ' \
                                    "place?\n",
                                    "<<some prefix/002>>\n" \
                                    "<<face: Actor4, 0>>\n" \
                                    "I don't know. You tell me!\n"
      end

      it 'returns a converted command list' do
        expect(@new_page[0]).to be page_1[0]
        expect(@new_page[1].code).to be 401
        expect(@new_page[1].parameters).to eq ['\dialogue![some prefix/001]']
        expect(@new_page[2]).to be page_1[3]
        expect(@new_page[3].code).to be 401
        expect(@new_page[3].parameters).to eq ['\dialogue![some prefix/002]']

        expect(@new_page.length).to be 4
      end
    end
  end
end
