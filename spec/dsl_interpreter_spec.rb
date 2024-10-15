BASE_PATH = '/Users/davidcruwys/dev/appydave/klueless'

file_list = [
  'docs/dsls/tools-as-code/context-gather',
  'docs/dsls/tools-as-code/build-prompt',
  'docs/dsls/media-as-code/storyboard-graphics',
  'docs/dsls/agent-as-code/youtube-launch-optimizer'
]

file = 'docs/dsls/marketing-as-code/lars/keyword-research-and-clustering'
file = 'docs/dsls/thai-business-costing/coffee-shop'
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

