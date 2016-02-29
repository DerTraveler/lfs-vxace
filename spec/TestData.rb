# encoding: UTF-8

EVENT_PAGE = [RPG::EventCommand.new(101, 0, ['Actor1', 0, 0, 2]),
              RPG::EventCommand.new(401, 0, ['Hello,']),
              RPG::EventCommand.new(401, 0, ['what are you doing in this' \
                                             ' lonely place?']),
              RPG::EventCommand.new(102, 0, [['(Get angry)',
                                              '(Stay silent)'], 2]),
              RPG::EventCommand.new(402, 0, [0, '(Get angry)']),
              RPG::EventCommand.new(101, 1, ['Actor4', 2, 0, 0]),
              RPG::EventCommand.new(401, 1, ["I don't know. You tell me," \
                                             ' idiot!']),
              RPG::EventCommand.new(0, 1, []),   # Branch End
              RPG::EventCommand.new(402, 0, [1, '(Stay silent)']),
              RPG::EventCommand.new(101, 1, ['Actor4', 2, 1, 1]),
              RPG::EventCommand.new(401, 1, ['(Not sure what I should' \
                                             ' say)']),
              RPG::EventCommand.new(0, 1, []),   # Branch End
              RPG::EventCommand.new(404, 0, []), # Choice Options End
              RPG::EventCommand.new(0, 0, [])]   # Event End