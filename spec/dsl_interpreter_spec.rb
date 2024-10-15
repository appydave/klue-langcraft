# frozen_string_literal: true

BASE_PATH = '/Users/davidcruwys/dev/appydave/klueless'
file = 'docs/dsls/tools-as-code/code-explorer'

file_list = [file]

file_list.each do |file|
  file = file.gsub(/\.klue$/, '')

  input_file = "#{file}.klue"
  output_file = "#{file}.json"
  interpreter = DSLInterpreter.new
  interpreter.evaluate_file(BASE_PATH, input_file, output_file)
  # puts JSON.pretty_generate(interpreter.to_hash)

  interpreter.send_to_endpoint
end
