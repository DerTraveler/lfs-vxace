# encoding: UTF-8

require 'stringio'

# Runs the given block and returns all the output to $stdout as a String.
def capture_output
  old_stdout = $stdout
  $stdout = StringIO.new
  yield
  result = $stdout.string
  $stdout = old_stdout
  result
end
