# frozen_string_literal: true

module Klue
  module Langcraft
    module DSL
      module Processors
        # FileCollectorProcessor class for processing file-related data
        #
        # This processor is responsible for handling file collection operations
        # within the DSL. It inherits from the base Processor class and implements
        # specific logic for file-related processing.
        class FileCollectorProcessor < Processor
          def self.keys
            [:file_collector]
          end

          def build_result_data
            working_directory = File.expand_path(data[:root])

            options = Appydave::Tools::GptContext::Options.new(
              working_directory: working_directory,
              include_patterns: extract_patterns(data.dig(:files, :include)),
              exclude_patterns: extract_patterns(data.dig(:files, :exclude)),
              format: 'json',
              line_limit: data[:line_length]
            )

            collector = Appydave::Tools::GptContext::FileCollector.new(options)
            json = collector.build

            {
              working_directory: working_directory,
              files: JSON.parse(json)
            }
          rescue StandardError => e
            puts "Error in FileCollectorProcessor: #{e.message}"
            puts e.backtrace.join("\n")
            {}
          end

          private

          def extract_patterns(files_data)
            if files_data.is_a?(Hash)
              [files_data[:p1]]
            elsif files_data.is_a?(Array)
              files_data.map { |entry| entry[:p1] }
            else
              []
            end
          end

          # Auto-register the processor as soon as the class is loaded
          ProcessorConfigDefault.register_processor(self)
        end
      end
    end
  end
end
