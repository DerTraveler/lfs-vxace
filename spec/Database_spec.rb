# encoding: UTF-8

require_relative 'TestPreparation'

describe 'Database objects' do
  before(:all) do
    $data_actors = load_data('Data/Actors.rvdata2')
    $data_classes = load_data('Data/Classes.rvdata2')
    $data_skills = load_data('Data/Skills.rvdata2')
    $data_items = load_data('Data/Items.rvdata2')
    $data_weapons = load_data('Data/Weapons.rvdata2')
    $data_armors = load_data('Data/Armors.rvdata2')
    $data_enemies = load_data('Data/Enemies.rvdata2')
    $data_states = load_data('Data/States.rvdata2')
    $data_system = load_data('Data/System.rvdata2')
    $game_message = Game_Message.new
    $game_party = Game_Party.new
  end

  describe RPG::Actor do
    before(:all) do
      $data_system = load_data('Data/System.rvdata2')
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

  describe RPG::Class do
    before(:all) do
      LanguageFileSystem.send(:clear_database)
      LanguageFileSystem.database[:classes][:name][1] = 'Ninja'
      LanguageFileSystem.database[:classes][:note][2] = 'This is very special'
      LanguageFileSystem.database[:classes][:learnings_note][2] = \
        { 3 => "This skill is dangerous!\nReally!" }
      LanguageFileSystem.send(:initialize_database)
    end

    it 'shows the information from the database hash' do
      expect($data_classes[1].name).to eq 'Ninja'
      expect($data_classes[2].note).to eq 'This is very special'
      expect($data_classes[2].learnings[3].note).to eq \
        "This skill is dangerous!\nReally!"
    end

    it 'does not change other information' do
      expect($data_classes[1].note).to eq ''
      expect($data_classes[2].name).to eq 'Monk'
    end
  end

  describe RPG::Skill do
    before(:all) do
      LanguageFileSystem.send(:clear_database)
      LanguageFileSystem.database[:skills][:name][1] = "Hit 'em"
      LanguageFileSystem.database[:skills][:description][1] = \
        'Fists and Feet. No bites please, girls!'
      LanguageFileSystem.database[:skills][:message1][3] = \
        ' attacks twice!'
      LanguageFileSystem.database[:skills][:message2][3] = \
        'POW! BAM!'
      LanguageFileSystem.database[:skills][:note][3] = \
        'Careful with this one!'
    end

    it 'shows the information from the database hash' do
      expect($data_skills[1].name).to eq "Hit 'em"
      expect($data_skills[1].description).to eq \
        'Fists and Feet. No bites please, girls!'
      expect($data_skills[3].message1).to eq ' attacks twice!'
      expect($data_skills[3].message2).to eq 'POW! BAM!'
      expect($data_skills[3].note).to eq 'Careful with this one!'
    end

    it 'does not change other information' do
      expect($data_skills[1].message1).to eq ' attacks!'
      expect($data_skills[1].message2).to eq ''
      expect($data_skills[1].note).to eq \
        "Skill #1 will be used when you select\r\nthe Attack command."
      expect($data_skills[3].name).to eq 'Dual Attack'
      expect($data_skills[3].description).to eq 'Hits an enemy twice!'
    end
  end

  describe RPG::Item do
    before(:all) do
      LanguageFileSystem.send(:clear_database)
      LanguageFileSystem.database[:items][:name][1] = 'Wodka'
      LanguageFileSystem.database[:items][:description][1] = 'Gets you drunk'
      LanguageFileSystem.database[:items][:note][2] = 'Hi???'
    end

    it 'shows the information from the database hash' do
      expect($data_items[1].name).to eq 'Wodka'
      expect($data_items[1].description).to eq 'Gets you drunk'
      expect($data_items[2].note).to eq 'Hi???'
    end

    it 'does not change other information' do
      expect($data_items[1].note).to eq ''
      expect($data_items[2].name).to eq 'Hi-Potion'
      expect($data_items[2].description).to eq 'Recovers 2,500 HP.'
    end
  end

  describe RPG::Weapon do
    before(:all) do
      LanguageFileSystem.send(:clear_database)
      LanguageFileSystem.database[:weapons][:name][1] = 'Boomerang'
      LanguageFileSystem.database[:weapons][:description][1] = \
        'Right back at ya!'
      LanguageFileSystem.database[:weapons][:note][2] = \
        'Usable only by Barbarians'
    end

    it 'shows the information from the database hash' do
      expect($data_weapons[1].name).to eq 'Boomerang'
      expect($data_weapons[1].description).to eq 'Right back at ya!'
      expect($data_weapons[2].note).to eq 'Usable only by Barbarians'
    end

    it 'does not change other information' do
      expect($data_weapons[1].note).to eq ''
      expect($data_weapons[2].name).to eq 'Battle Axe'
      expect($data_weapons[2].description).to eq \
        'Double-sided axe made for combat.'
    end
  end

  describe RPG::Armor do
    before(:all) do
      LanguageFileSystem.send(:clear_database)
      LanguageFileSystem.database[:armors][:name][1] = 'Mark 43 XLIII'
      LanguageFileSystem.database[:armors][:description][1] = \
        'Made by Stark Industries'
      LanguageFileSystem.database[:armors][:note][2] = \
        '(name subject to change)'
    end

    it 'shows the information from the database hash' do
      expect($data_armors[1].name).to eq 'Mark 43 XLIII'
      expect($data_armors[1].description).to eq 'Made by Stark Industries'
      expect($data_armors[2].note).to eq '(name subject to change)'
    end

    it 'does not change other information' do
      expect($data_armors[1].note).to eq ''
      expect($data_armors[2].name).to eq 'Leather Top'
      expect($data_armors[2].description).to eq \
        'Made with the best leather.'
    end
  end

  describe RPG::Enemy do
    before(:all) do
      LanguageFileSystem.send(:clear_database)
      LanguageFileSystem.database[:enemies][:name][1] = 'Slimeking'
      LanguageFileSystem.database[:enemies][:note][2] = 'TODO: Research!'
    end

    it 'shows the information from the database hash' do
      expect($data_enemies[1].name).to eq 'Slimeking'
      expect($data_enemies[2].note).to eq 'TODO: Research!'
    end

    it 'does not change other information' do
      expect($data_enemies[1].note).to eq ''
      expect($data_enemies[2].name).to eq 'Bat'
    end
  end

  describe RPG::State do
    before(:all) do
      LanguageFileSystem.send(:clear_database)
      LanguageFileSystem.database[:states][:name][1] = 'Reading Steiner'
      LanguageFileSystem.database[:states][:message1][1] = \
        ' changed world line!'
      LanguageFileSystem.database[:states][:message2][1] = \
        ' seems to have a headache!'
      LanguageFileSystem.database[:states][:message3][1] = \
        ' reads divergence: 1.048596'
      LanguageFileSystem.database[:states][:message4][1] = \
        ' has returned!'
      LanguageFileSystem.database[:states][:note][2] = 'El Psy Kongroo'
    end

    it 'shows the information from the database hash' do
      expect($data_states[1].name).to eq 'Reading Steiner'
      expect($data_states[1].message1).to eq ' changed world line!'
      expect($data_states[1].message2).to eq ' seems to have a headache!'
      expect($data_states[1].message3).to eq ' reads divergence: 1.048596'
      expect($data_states[1].message4).to eq ' has returned!'
      expect($data_states[2].note).to eq 'El Psy Kongroo'
    end

    it 'does not change other information' do
      expect($data_states[1].note).to eq \
        "State #1 will be automatically added when\r\nHP reaches 0."
      expect($data_states[2].name).to eq 'Poison'
      expect($data_states[2].message1).to eq ' is poisoned!'
      expect($data_states[2].message2).to eq ' is poisoned!'
      expect($data_states[2].message3).to eq ''
      expect($data_states[2].message4).to eq ' is freed of poison!'
    end
  end

  describe RPG::System do
    before(:all) do
      LanguageFileSystem.send(:clear_database)
      LanguageFileSystem.database[:system][:game_title] = 'Steins;Gate 0'
      LanguageFileSystem.database[:system][:currency_unit] = 'JPY'
      LanguageFileSystem.database[:types][:elements][1] = 'Black Matter'
      LanguageFileSystem.database[:types][:skill_types][2] = 'Military Training'
      LanguageFileSystem.database[:types][:weapon_types][3] = 'Pistol'
      LanguageFileSystem.database[:types][:armor_types][4] = 'Body Suit'
      LanguageFileSystem.database[:terms][:basic][0] = 'Div.'
      LanguageFileSystem.database[:terms][:params][1] = 'Madness'
      LanguageFileSystem.database[:terms][:etypes][2] = 'Drink'
      LanguageFileSystem.database[:terms][:commands][3] = 'Call Organization'
      LanguageFileSystem.send(:initialize_database)
    end

    it 'shows the information from the database hash' do
      expect($data_system.game_title).to eq 'Steins;Gate 0'
      expect($data_system.currency_unit).to eq 'JPY'
      expect($data_system.elements[1]).to eq 'Black Matter'
      expect($data_system.skill_types[2]).to eq 'Military Training'
      expect($data_system.weapon_types[3]).to eq 'Pistol'
      expect($data_system.armor_types[4]).to eq 'Body Suit'
      expect($data_system.terms.basic[0]).to eq 'Div.'
      expect($data_system.terms.params[1]).to eq 'Madness'
      expect($data_system.terms.etypes[2]).to eq 'Drink'
      expect($data_system.terms.commands[3]).to eq 'Call Organization'
    end

    it 'does not change other information' do
      expect($data_system.elements[2]).to eq 'Absorb'
      expect($data_system.skill_types[1]).to eq 'Special'
      expect($data_system.weapon_types[4]).to eq 'Sword'
      expect($data_system.armor_types[5]).to eq 'Small Shield'
      expect($data_system.terms.basic[1]).to eq 'LV'
      expect($data_system.terms.params[2]).to eq 'ATK'
      expect($data_system.terms.etypes[3]).to eq 'Bodygear'
      expect($data_system.terms.commands[4]).to eq 'Items'
    end
  end
end
