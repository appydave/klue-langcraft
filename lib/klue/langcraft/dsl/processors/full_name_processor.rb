# frozen_string_literal: true

module Klue
  module Langcraft
    module DSL
      module Processors
        # FullNameProcessor class for processing full name data
        #
        # This processor is responsible for handling full name processing operations
        # within the DSL. It inherits from the base Processor class and implements
        # specific logic for full name-related processing.
        class FullNameProcessor < Processor
          def self.keys
            [:full_name] # FullNameProcessor's specific key(s)
          end

          # Implementation of logic for building full name data
          def build_result_data
            first_name = data[:first_name] || 'John'
            last_name = data[:last_name] || 'Doe'
            full_name = "#{first_name} #{last_name}"

            {
              full_name: full_name
            }
          end

          # Auto-register the processor as soon as the class is loaded
          ProcessorConfigDefault.register_processor(self)
        end
      end
    end
  end
end
