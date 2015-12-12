describe LanguageFileSystem do

  before(:each) do
    LanguageFileSystem::clear_dialogues
  end

  describe "#add_dialogue" do
    context "when the ID is not yet assigned to a dialogue" do
      it "adds the dialogue to the hash" do
        LanguageFileSystem::add_dialogue("another test", "Another dialogue")

        expect(LanguageFileSystem::dialogues).to include("another test" => "Another dialogue")
      end
    end

    context "when the ID is already assigned to a dialogue" do
      it "overwrites the existing dialogue" do
        LanguageFileSystem::add_dialogue("hello there", "Hi! How are you?")
        LanguageFileSystem::add_dialogue("hello there", "Greetings!")

        expect(LanguageFileSystem::dialogues).to include("hello there" => "Greetings!")
      end
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

  describe "#clear_dialogue" do
    it "removes all dialogues" do
      expect(LanguageFileSystem::dialogues).to eq({})
    end
  end

end
