# encoding: UTF-8

PAGE = \
  [RPG::EventCommand.new(105, 0, [4, true]),
   RPG::EventCommand.new(405, 0, ['Witness a dramatic meeting']),
   RPG::EventCommand.new(405, 0, ['Of two men']),
   RPG::EventCommand.new(405, 0, ['Two men that should become enemies']),
   RPG::EventCommand.new(405, 0, ['Two men that should become allies']),
   RPG::EventCommand.new(405, 0, ['Let the games begin']),
   RPG::EventCommand.new(101, 0, ['Actor1', 0, 0, 2]),
   RPG::EventCommand.new(401, 0, ['Hello,']),
   RPG::EventCommand.new(401, 0, ['what are you doing in this lonely place?']),
   RPG::EventCommand.new(102, 0, [['(Get angry)',
                                   '(Stay silent)'], 2]),
   RPG::EventCommand.new(402, 0, [0, '(Get angry)']),
   RPG::EventCommand.new(101, 1, ['Actor4', 2, 0, 0]),
   RPG::EventCommand.new(401, 1, ["I don't know. You tell me, idiot!"]),
   RPG::EventCommand.new(0, 1, []),   # Branch End
   RPG::EventCommand.new(402, 0, [1, '(Stay silent)']),
   RPG::EventCommand.new(101, 1, ['Actor4', 2, 1, 1]),
   RPG::EventCommand.new(401, 1, ['(Not sure what I should say)']),
   RPG::EventCommand.new(0, 1, []),   # Branch End
   RPG::EventCommand.new(404, 0, []), # Choice Options End
   RPG::EventCommand.new(101, 0, ['', 0, 0, 2]),
   RPG::EventCommand.new(401, 0, ['Hint:']),
   RPG::EventCommand.new(401, 0, ['Try to find another way to approach that' \
                                  ' person.']),
   RPG::EventCommand.new(0, 0, [])]   # Event End

PAGE_EXTRACTED = \
  [RPG::EventCommand.new(101, 0, ['Actor1', 0, 0, 2]),
   RPG::EventCommand.new(401, 0, ['\dialogue[some prefix/001:Hello,]']),
   RPG::EventCommand.new(102, 0,
                         [['\dialogue[some prefix/002-0:Getangr]',
                           '\dialogue[some prefix/002-1:Staysil]',
                           '(Glare at him)'], 2]),
   RPG::EventCommand.new(402, 0, [0, '(Get angry)']),
   RPG::EventCommand.new(101, 1, ['Actor4', 2, 0, 0]),
   RPG::EventCommand.new(401, 1, ['\dialogue[some prefix/' \
                                  "003:Idon'tknowYoutellme,]"]),
   RPG::EventCommand.new(0, 1, []),   # Branch End
   RPG::EventCommand.new(402, 0, [1, '(Stay silent)']),
   RPG::EventCommand.new(101, 1, ['Actor4', 2, 1, 1]),
   RPG::EventCommand.new(401, 1, ['\dialogue[some prefix/' \
                                  '004:NotsurewhatIshouldsa]']),
   RPG::EventCommand.new(0, 1, []),   # Branch End
   RPG::EventCommand.new(402, 0, [2, '(Glare at him)']),
   RPG::EventCommand.new(101, 1, ['Actor1', 0, 0, 2]),
   RPG::EventCommand.new(401, 1, ['Whoa, man! Calm down!']),
   RPG::EventCommand.new(0, 1, []),   # Branch End
   RPG::EventCommand.new(404, 0, []), # Choice Options End
   RPG::EventCommand.new(0, 0, [])]   # Event End

RVTEXT_SIMPLE = ['<<a simple id>>',
                 'Blablabla',
                 '<<MultilineMessage>>',
                 'I see...',
                 '# This is a comment line',
                 'So this is how you think about it.']

RVTEXT_WITH_OPTIONS = ['<<good message>>',
                       '<<face: Actor2, 4>>',
                       '<<position: top>>',
                       'Good evening sir! This is a good message!',
                       '<<empty bad message>>',
                       '<<face: MrX, 12>>',
                       '<<scroll_speed: -12>>',
                       '<<bad message>>',
                       '<<face: blabla>>',
                       '<<special_flag: one>>',
                       '<<position: yellow>>',
                       '<<scroll_no_fast: Excalibur>>',
                       '<<background: dim>>',
                       'Sorry for the trouble caused by me!']

RVTEXT_OLD = ['<<OldScrollMessage>>',
              '<<no_fast>>',
              'Take it easy!',
              '<<HelloThere>>',
              '<<background: transparent>>',
              'What was that???']

FILES = { 'SimpleFile.rvtext' => RVTEXT_SIMPLE,
          'FileWithOptions.rvtext' => RVTEXT_WITH_OPTIONS,
          'OldFile.rvtext' => RVTEXT_OLD }

RSpec.configure do |c|

  c.before(:suite) do
    FILES.each do |filename, content|
      open(filename, 'w:UTF-8') do |f|
        f.write(content.join("\n") + "\n")
      end
    end
  end

  c.after(:suite) do
    File.delete(*FILES.keys)
  end

  c.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  c.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  c.order = :random
  Kernel.srand c.seed

end
