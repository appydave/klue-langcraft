# frozen_string_literal: true

module Klue
  module Langcraft
    module DSL
      module Processors
        # Base Processor class for defining common processor behavior
        #
        # This abstract class serves as the foundation for all specific processors.
        # It defines the basic structure and common methods that all processors
        # should implement or inherit.
        class Processor
          attr_reader :data, :key

          # Every processor subclass must accept data and key
          def initialize(data, key)
            @data = Marshal.load(Marshal.dump(data)) # Deep clone of the data
            @key = key
          end

          # Build an envelope result with type, name, and data
          def build_result
            {
              name: data.is_a?(Hash) ? data['as'] : nil,
              type: key.to_s,
              data: build_result_data
            }
          end

          # Subclasses should override this method to build the actual data.
          def build_result_data
            raise NotImplementedError, 'Subclasses must implement `build_data` to generate their specific data'
          end

          # This will be overridden by subclasses to define keys (or aliases)
          def self.keys
            raise NotImplementedError, 'Subclasses must define the `keys` method'
          end
        end
      end
    end
  end
end
