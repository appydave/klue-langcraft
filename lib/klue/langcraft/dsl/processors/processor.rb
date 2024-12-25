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
            @data = clone(data)
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

          private

          def clone(data)
            deep_transform_keys(Marshal.load(Marshal.dump(data)))
          end

          def deep_transform_keys(hash)
            hash.each_with_object({}) do |(key, value), result|
              # Use the block if given, otherwise convert keys to symbols by default
              transformed_key = block_given? ? yield(key) : key.to_sym

              result[transformed_key] = case value
                                        when Hash
                                          deep_transform_keys(value) { |k| block_given? ? yield(k) : k.to_sym }
                                        when Array
                                          value.map do |v|
                                            if v.is_a?(Hash)
                                              deep_transform_keys(v) { |k| block_given? ? yield(k) : k.to_sym }
                                            else
                                              v
                                            end
                                          end
                                        else
                                          value
                                        end
            end
          end
        end
      end
    end
  end
end
