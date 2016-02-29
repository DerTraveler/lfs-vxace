# encoding: UTF-8

describe LanguageFileSystem do

  before(:each) do
    LanguageFileSystem.clear_dialogues
  end

  describe '#add_dialogue' do
    it 'adds the dialogue to the hash' do
      LanguageFileSystem.add_dialogue('another test', 'Another dialogue')

      expect(LanguageFileSystem.dialogues).to include('another test' =>
                                                      'Another dialogue')
    end

    it 'overwrites the existing dialogues' do
      LanguageFileSystem.add_dialogue('hello there', 'Hi! How are you?')
      LanguageFileSystem.add_dialogue('hello there', 'Greetings!')

      expect(LanguageFileSystem.dialogues).to include('hello there' =>
                                                      'Greetings!')
    end
  end

  describe '#dialogues' do
    it 'returns just a copy of the dialogue hash' do
      LanguageFileSystem.add_dialogue('special id', 'Have fun!')

      # Change returned object
      result = LanguageFileSystem.dialogues
      result['another id'] = 'Go away!'

      expect(LanguageFileSystem.dialogues).to eq('special id' => 'Have fun!')
    end
  end

  describe '#set_dialogue_options' do
    context 'when the options are valid' do
      it 'adds the options to the hash' do
        LanguageFileSystem.set_dialogue_options('test', face_name: 'Actor1',
                                                        face_index: 3,
                                                        position: 'top',
                                                        background: 'dim')

        expect(LanguageFileSystem.dialogue_options).to \
          include('test' => { face_name: 'Actor1', face_index: 3,
                              position: 'top', background: 'dim' })
      end

      it 'overwrites the existing options' do
        LanguageFileSystem.set_dialogue_options('hello there',
                                                position: 'middle')
        LanguageFileSystem.set_dialogue_options('hello there',
                                                position: 'bottom')

        expect(LanguageFileSystem.dialogue_options).to \
          include('hello there' => { position: 'bottom' })
      end
    end

    def lfs_sdo(id, options)
      LanguageFileSystem.set_dialogue_options(id, options)
    end

    context 'when encountering an unknown option' do
      it 'raises an error and does not add the option' do
        # lfs_sdo = LanguageFileSystem.set_dialogue_options
        expect { lfs_sdo('risky', special_option: 'wololo') }.to \
          raise_error(ArgumentError)

        expect(LanguageFileSystem.dialogue_options).to eq({})
      end
    end

    context 'when encountering invalid value' do
      it 'raises an error and does not add the option' do
        # lfs_sdo = LanguageFileSystem.set_dialogue_options

        # face_index out of bounds
        expect { lfs_sdo('wrong', face_index: 12) }.to \
          raise_error(ArgumentError, "'face_index' must be between 0 and 7")
        # position not one of 'top', 'middle', 'bottom'
        expect { lfs_sdo('ambitious', position: -7) }.to \
          raise_error(ArgumentError,
                      "'position' must be 'top', 'middle' or 'bottom'")
        # background not one of 'normal', 'dim', 'transparent'
        expect { lfs_sdo('nice try', background: 'top') }.to \
          raise_error(ArgumentError,
                      "'background' must be 'normal', 'dim' or 'transparent'")

        expect(LanguageFileSystem.dialogue_options).to eq({})
      end
    end

    context 'when encountering incomplete face options' do
      it 'raises an error and does not add the option' do
        # lfs_sdo = LanguageFileSystem.set_dialogue_options

        # only face_name
        expect { lfs_sdo('which Albert?', face_name: 'Albert') }.to \
          raise_error(ArgumentError,
                      "'face_name' specified without 'face_index'!")
        # only face index
        expect { lfs_sdo('Number 3?', face_index: 3) }.to \
          raise_error(ArgumentError,
                      "'face_index' specified without 'face_name'!")

        expect(LanguageFileSystem.dialogue_options).to eq({})
      end
    end
  end

  describe '#dialogue_options' do
    it 'returns just a copy of the dialogue option hash' do
      LanguageFileSystem.set_dialogue_options('special id', position: 'middle')

      # Change returned object
      result = LanguageFileSystem.dialogue_options
      result['another id'] = { position: 'bottom' }

      expect(LanguageFileSystem.dialogue_options).to eq(
        'special id' => { position: 'middle' })
    end
  end

  describe '#clear_dialogue' do
    it 'removes all dialogues' do
      expect(LanguageFileSystem.dialogues).to eq({})
    end

    it 'removes all dialogue options' do
      expect(LanguageFileSystem.dialogue_options).to eq({})
    end
  end

end
