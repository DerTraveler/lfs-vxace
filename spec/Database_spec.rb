# encoding: UTF-8

require_relative 'TestPreparation'

describe 'Database objects' do
  before(:all) do
    $data_actors = load_data('Data/Actors.rvdata2')
    $data_classes = load_data('Data/Classes.rvdata2')
    $data_weapons = load_data('Data/Weapons.rvdata2')
    $data_armors = load_data('Data/Armors.rvdata2')
    $data_states = load_data('Data/States.rvdata2')
    $data_system = load_data('Data/System.rvdata2')
    $game_message = Game_Message.new
    $game_party = Game_Party.new
  end

  describe RPG::Actor do
    before(:all) do
      LanguageFileSystem.send(:clear_database)
      LanguageFileSystem.database[:actors][:name][1] = 'Dieter'
      LanguageFileSystem.database[:actors][:nickname][1] = 'Silver Surfer'
      LanguageFileSystem.database[:actors][:description][2] = \
        "No one knows where she is\nfrom or what her intentions are."
      LanguageFileSystem.database[:actors][:note][2] = \
        "message option\n1,2,3\nend"
    end

    it 'shows the information from the database hash' do
      expect($data_actors[1].name).to eq 'Dieter'
      expect($data_actors[1].nickname).to eq 'Silver Surfer'
      expect($data_actors[2].description).to eq \
        "No one knows where she is\nfrom or what her intentions are."
      expect($data_actors[2].note).to eq "message option\n1,2,3\nend"
    end

    it 'does not change other information' do
      expect($data_actors[1].description).to eq \
        "A veteran warrior who fought on many battlefields.\r\n" \
        'He becomes uncontrollable in battle when berserk.'
      expect($data_actors[1].note).to eq ''
      expect($data_actors[2].name).to eq 'Natalie'
      expect($data_actors[2].nickname).to eq 'Thunder Fist'
    end

    describe Game_Actor do
      let(:actor1) { Game_Actor.new(1) }
      let(:actor2) { Game_Actor.new(2) }

      it 'shows the information from the database hash' do
        expect(actor1.name).to eq 'Dieter'
        expect(actor1.nickname).to eq 'Silver Surfer'
      end

      it 'shows original if nothing in the database hash' do
        expect(actor2.name).to eq 'Natalie'
        expect(actor2.nickname).to eq 'Thunder Fist'
      end

      it 'shows the correct level up message' do
        $game_message.clear
        actor1.display_level_up([])
        expect($game_message.all_text).to eq "Dieter is now Level 1!\n"
      end

      context 'when (nick)name is changed' do
        before(:each) do
          LanguageFileSystem.send(:clear_database)
          LanguageFileSystem.database[:names]['HeroNewName'] = 'He-Man'
          LanguageFileSystem.database[:names]['EpicTitle'] = 'Hero of Grayskull'
          actor1.name = '\name[HeroNewName]'
          actor1.nickname = '\name[EpicTitle]'
        end

        it 'shows the new names' do
          expect(actor1.name).to eq 'He-Man'
          expect(actor1.nickname).to eq 'Hero of Grayskull'
        end

        it 'shows the correct level up message' do
          $game_message.clear
          actor1.display_level_up([])
          expect($game_message.all_text).to eq "He-Man is now Level 1!\n"
        end
      end
    end
  end
end
