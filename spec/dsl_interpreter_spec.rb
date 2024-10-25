# frozen_string_literal: true

# DEPRECATE WHEN REFACTOR IS COMPLETE
# BASE_PATH = '/Users/davidcruwys/dev/ad/klueless' # /klue-langcraft'
# initial_file = 'docs/dsls/tools-as-code/code-explorer'

# file_list = [initial_file]

# file_list.each do |current_file|
#   current_file = current_file.gsub(/\.klue$/, '')

#   input_file = "#{current_file}.klue"
#   output_file = "#{current_file}.json"
#   extended_output_file = "#{current_file}-extended.json"

#   interpreter = DSLInterpreter.new
#   dsl_processor = DSLProcessData.new

#   interpreter.process(BASE_PATH, input_file, output_file)
#   # puts JSON.pretty_generate(interpreter.to_hash)
#   dsl_processor.process(BASE_PATH, output_file, extended_output_file)

#   # interpreter.send_to_endpoint
# end
