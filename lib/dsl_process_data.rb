# frozen_string_literal: true

class DSLProcessData
  PROCESSORS = [{ file_collector: ProcessFileCollector }].freeze

  # Method to process the JSON file after initial evaluation
  def process(base_path, input_file, output_file)
    json_file_path = File.join(base_path, input_file)
    data = JSON.parse(File.read(json_file_path))

    # Loop through the processors and execute matching ones
    PROCESSORS.each do |processor_entry|
      key, processor_class = processor_entry.first
      processor = processor_class.new(key)

      next unless processor.match?(data)

      result = processor.execute(data)

      data['process-data'] ||= {}

      result.each do |key, result|
        data['process-data'][key.to_s] = result unless result.empty?
      end
    end

    # Write the updated JSON data to an extended file
    extended_output_file = File.join(base_path, output_file)
    File.write(extended_output_file, JSON.pretty_generate(data))
  end
end
