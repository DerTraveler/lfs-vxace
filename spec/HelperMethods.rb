# encoding: UTF-8

require 'stringio'

def capture_output
  old_stdout = $stdout
  $stdout = StringIO.new
  yield
  result = $stdout.string
  $stdout = old_stdout
  result
end
