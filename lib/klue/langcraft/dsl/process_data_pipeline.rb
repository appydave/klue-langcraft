# frozen_string_literal: true

module Klue
  module Langcraft
    module DSL
      # ProcessDataPipeline class for executing data processing pipelines
      #
      # This class is responsible for executing a series of data processing steps
      # based on the configured processors. It manages the flow of data through
      # the pipeline and handles the storage of results.
      class ProcessDataPipeline
        def initialize(matcher)
          @matcher = matcher # Use the matcher to find processors
        end

        # Execute the pipeline of processors on the input data
        def execute(data)
          # NOTE: This is the complete data object, each processor will get a cloned version the specific data it is matched to
          matched_processors = @matcher.match_processors(data)

          matched_processors.each do |processor|
            processed_data = processor.build_result

            # Store the processed data into the result structure
            store_result(data, processor, processed_data)
          end

          data
        end

        # Optionally write the output to a file
        def write_output(data, output_file)
          File.write(output_file, JSON.pretty_generate(data))
        end

        private

        # Store the processed result back into the data structure
        def store_result(data, _processor, processed_data)
          return unless processed_data

          data['process-data'] ||= {}

          if processed_data[:name].nil? || processed_data[:name].empty?
            index = calculate_index(data, processed_data[:type])
            processed_data[:name] = "#{processed_data[:type]}-#{index}"
          end

          data['process-data'][processed_data[:name]] = processed_data
        end

        def calculate_index(data, processor_type)
          # Find all keys in 'process-data' that match the processor type (e.g., file_collector)
          last_index = data['process-data'].keys
                                           .select { |k| k.start_with?(processor_type.to_s) }  # Keys that start with processor type
                                           .map { |k| k.split('-').last.to_i }                 # Extract numeric suffix
                                           .max

          # If no entries exist, start at 1; otherwise, increment the last index
          last_index ? last_index + 1 : 1
        end
      end
    end
  end
end
