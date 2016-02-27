describe LanguageFileSystem do

  before(:each) do
    LanguageFileSystem::clear_dialogues
  end

  describe "#add_dialogue" do
    it "adds the dialogue to the hash" do
      LanguageFileSystem::add_dialogue("another test", "Another dialogue")

      expect(LanguageFileSystem::dialogues).to include("another test" => "Another dialogue")
    end

    it "overwrites the existing dialogues" do
      LanguageFileSystem::add_dialogue("hello there", "Hi! How are you?")
      LanguageFileSystem::add_dialogue("hello there", "Greetings!")

      expect(LanguageFileSystem::dialogues).to include("hello there" => "Greetings!")
    end
  end

  describe "#dialogues" do
    it "returns just a copy of the dialogue hash" do
      LanguageFileSystem::add_dialogue("special id", "Have fun!")
      # Change returned object
      result = LanguageFileSystem::dialogues
      result["another id"] = "Go away!"

      expect(LanguageFileSystem::dialogues).to eq({"special id" => "Have fun!"})
    end
  end

  describe "#set_dialogue_options" do
    context "when the options are valid" do
      it "adds the options to the hash" do
        LanguageFileSystem::set_dialogue_options("test", { position: "top" })

        expect(LanguageFileSystem::dialogue_options).to include("test" => { position: "top" })
      end

      it "overwrites the existing options" do
        LanguageFileSystem::set_dialogue_options("hello there", { position: "middle" })
        LanguageFileSystem::set_dialogue_options("hello there", { position: "bottom" })

        expect(LanguageFileSystem::dialogue_options).to include("hello there" => { position: "bottom" })
      end
    end

    context "when encountering an unknown option" do
      it "raises an error and does not add the option" do
        expect {
          LanguageFileSystem::set_dialogue_options("risky", { special_option: "wololo"})
        }.to raise_error(ArgumentError) { |error| expect(error.message).to include("special_option") }
        expect(LanguageFileSystem::dialogue_options).to eq({})
      end
    end

    context "when encountering invalid value"
      it "raises an error and does not add the option" do
        expect {
          LanguageFileSystem::set_dialogue_options("wrong", { face_index: 12 })
        }.to raise_error(ArgumentError)

        expect {
          LanguageFileSystem::set_dialogue_options("ambitious", { position: -7 })
        }.to raise_error(ArgumentError)

        expect {
          LanguageFileSystem::set_dialogue_options("nice try", { background: "top" })
        }.to raise_error(ArgumentError)
      end
  end

  describe "#dialogue_options" do
    it "returns just a copy of the dialogue option hash" do
      LanguageFileSystem::set_dialogue_options("special id", { position: "middle" })
      # Change returned object
      result = LanguageFileSystem::dialogue_options
      result["another id"] = { position: "bottom" }

      expect(LanguageFileSystem::dialogue_options).to eq({"special id" => { position: "middle" }})
    end
  end

  describe "#clear_dialogue" do
    it "removes all dialogues" do
      expect(LanguageFileSystem::dialogues).to eq({})
    end

    it "removes all dialogue options" do
      expect(LanguageFileSystem::dialogue_options).to eq({})
    end
  end

end
