# frozen_string_literal: true

module Klue
  module Langcraft
    module DSL
      # ProcessorConfig class for managing processor configurations
      #
      # This class is responsible for registering processors and providing
      # methods to retrieve processors based on keys or to get all registered
      # processors.
      class ProcessorConfig
        def initialize
          @processors = {}
        end

        # Register a processor with its associated keys
        def register_processor(processor_class)
          keys = processor_class.keys
          keys = [keys] unless keys.is_a?(Array)
          keys.each { |key| @processors[key.to_sym] = processor_class }
        end

        # Find the processor class by key
        def processor_for(key)
          @processors[key.to_sym]
        end

        # List all registered processors
        def all_processors
          @processors
        end
      end
    end
  end
end
