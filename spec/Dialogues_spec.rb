# encoding: UTF-8

describe Game_Message do

  before(:each) do
    LanguageFileSystem.clear_dialogues
    LanguageFileSystem.add_dialogue('hello', 'Some dialogue')
    LanguageFileSystem.set_dialogue_options('hello',
                                            face_name: 'Actor1',
                                            face_index: 2,
                                            position: 'top',
                                            background: 'transparent',
                                            scroll_speed: 5,
                                            scroll_no_fast: 'true')
    LanguageFileSystem.add_dialogue('multiline',
                                    "This message\nhas several\nlines, yeah!")
    $game_message = Game_Message.new
  end

  context 'when a message' do
    context 'contains a \dialogue[...] tag' do
      context 'and the dialogue id exists' do
        it 'displays the dialogue instead of the original message' do
          $game_message.add("I say stuff that won't be seen")
          $game_message.add('because of this \dialogue[hello] tag.')

          expect($game_message.all_text).to eq "Some dialogue\n"
        end

        it 'also supports multiline dialogues' do
          $game_message.add('Hello, \dialogue[multiline]!')

          expect($game_message.all_text).to eq(
            "This message\nhas several\nlines, yeah!\n")
        end

        it 'does not affect later messages' do
          $game_message.add('Affected \dialogue[hello]!')
          $game_message.clear
          $game_message.add('Unaffected message!')

          expect($game_message.all_text).to eq "Unaffected message!\n"
        end

        it 'does NOT use the message options' do
          $game_message.add('\dialogue[hello]')

          expect($game_message.face_name).to eq ''
          expect($game_message.face_index).to eq 0
          expect($game_message.position).to eq 2
          expect($game_message.background).to eq 0
          expect($game_message.scroll_speed).to eq 2
          expect($game_message.scroll_no_fast).to be false
        end

        # it 'supports setting of message options' do
        #   $game_message.add('\dialogue[hello]')
        #
        #   expect($game_message.face_name).to eq 'Actor1'
        #   expect($game_message.face_index).to eq 2
        #   expect($game_message.position).to eq 0
        #   expect($game_message.background).to eq 2
        #   expect($game_message.scroll_speed).to eq 5
        #   expect($game_message.scroll_no_fast).to be true
        # end
      end

      context "but the dialogue id doesn't exist" do
        it 'displays the original message' do
          $game_message.add('I say stuff that WILL be seen')
          $game_message.add("because this doesn't exist: \\dialogue[wololo]")

          expect($game_message.all_text).to \
            eq("I say stuff that WILL be seen\n" \
               "because this doesn't exist: \\dialogue[wololo]\n")
        end
      end
    end

    context 'contains a \dialogue![...] tag' do
      context 'and the dialogue id exists' do
        it 'displays the dialogue instead of the original message' do
          $game_message.add("I say stuff that won't be seen")
          $game_message.add('because of this \dialogue![hello] tag.')

          expect($game_message.all_text).to eq "Some dialogue\n"
        end

        it 'also supports multiline dialogues' do
          $game_message.add('Hello, \dialogue![multiline]!')

          expect($game_message.all_text).to eq(
            "This message\nhas several\nlines, yeah!\n")
        end

        it 'does not affect later messages' do
          $game_message.add('Affected \dialogue![hello]!')
          $game_message.clear
          $game_message.add('Unaffected message!')

          expect($game_message.all_text).to eq "Unaffected message!\n"
        end

        it 'does use the message options' do
          $game_message.add('\dialogue![hello]')

          expect($game_message.face_name).to eq 'Actor1'
          expect($game_message.face_index).to eq 2
          expect($game_message.position).to eq 0
          expect($game_message.background).to eq 2
          expect($game_message.scroll_speed).to eq 5
          expect($game_message.scroll_no_fast).to be true
        end
      end

      context "but the dialogue id doesn't exist" do
        it 'displays the original message' do
          $game_message.add('I say stuff that WILL be seen')
          $game_message.add("because this doesn't exist: \\dialogue![wololo]")

          expect($game_message.all_text).to \
            eq("I say stuff that WILL be seen\n" \
               "because this doesn't exist: \\dialogue![wololo]\n")
        end
      end
    end

    context "doesn't contain such tag" do
      it 'shows the original message' do
        $game_message.add('Is this for real?')
        $game_message.add('Is this a fantasy?')

        expect($game_message.all_text).to \
          eq("Is this for real?\nIs this a fantasy?\n")
      end
    end
  end

  context 'when a choice' do

    subject(:interpreter) { Game_Interpreter.new }

    context 'contains a \dialogue[...] tag' do
      context 'and the dialogue id exists' do
        it 'shows the dialogue instead of the choice' do
          interpreter.setup_choices([['Do this!',
                                      'Or that!',
                                      '\dialogue[hello]'],
                                     0])

          expect($game_message.choices).to contain_exactly('Do this!',
                                                           'Or that!',
                                                           'Some dialogue')
        end

        it 'only shows the first line of a multiline message' do
          interpreter.setup_choices([['Good choice',
                                      'Better choice',
                                      '\dialogue[multiline]'],
                                     0])

          expect($game_message.choices).to contain_exactly('Good choice',
                                                           'Better choice',
                                                           'This message')
        end
      end

      context "but the dialogue id doesn't exist" do
        it 'displays the original choice' do
          interpreter.setup_choices([['A choice',
                                      'Oh another',
                                      '\dialogue[wololo]'],
                                     0])

          expect($game_message.choices).to contain_exactly('A choice',
                                                           'Oh another',
                                                           '\dialogue[wololo]')
        end
      end
    end

    context "doesn't contain a \dialogue[...] tag" do
      it 'shows the original choice' do
        interpreter.setup_choices([['A choice', 'Oh another', 'Choose me!'], 0])

        expect($game_message.choices).to contain_exactly('A choice',
                                                         'Oh another',
                                                         'Choose me!')
      end
    end

  end

end
