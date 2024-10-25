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

          # Example of how a subclass can implement its specific data logic
          def build_result_data
            {
              files: ['file1.txt', 'file2.txt']
            }
          end

          # Auto-register the processor as soon as the class is loaded
          ProcessorConfigDefault.register_processor(self)
        end
      end
    end
  end
end
