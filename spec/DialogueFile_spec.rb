describe LanguageFileSystem do

  before(:all) do
    open("SimpleFile.rvtext", "w:UTF-8") { |f|
      f.write("<<a simple id>>\n")
      f.write("Blablabla\n")
      f.write("<<EmptyMessage>>\n")
      f.write("<<MultilineMessage>>\n")
      f.write("I see...\n")
      f.write("# This is a comment line\n")
      f.write("So this is how you think about it.")
    }
  end

  after(:all) do
    File.delete("SimpleFile.rvtext")
  end

  describe "#load_rvtext" do
    it "loads the file into the dialogue hash" do
      LanguageFileSystem::load_rvtext("SimpleFile.rvtext")

      expect(LanguageFileSystem::dialogues).to contain_exactly(["a simple id", "Blablabla"],
                                                               ["EmptyMessage", ""],
                                                               ["MultilineMessage", "I see...\nSo this is how you think about it."])
    end

  end

end
