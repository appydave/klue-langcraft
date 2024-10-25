# frozen_string_literal: true

module Klue
  module Langcraft
    module DSL
      # ProcessMatcher class for matching processors to input nodes
      #
      # This class is responsible for traversing input nodes and finding
      # the appropriate processor for each node based on the configured
      # processor rules.
      class ProcessMatcher
        def initialize(processor_config = ProcessorConfigDefault)
          @processor_config = processor_config
        end

        def match_processors(nodes)
          matched_processors = []

          traverse_nodes(nodes) do |key, value|
            processor_class = find_processor_for(key, value)
            if processor_class
              if value.is_a?(Array)
                # If the value is an array, instantiate a processor for each element
                value.each do |element|
                  matched_processors << processor_class.new(element, key)
                end
              else
                matched_processors << processor_class.new(value, key)
              end
            end
          end

          matched_processors
        end

        private

        def traverse_nodes(node, &block)
          if node.is_a?(Hash)
            node.each do |key, value|
              yield(key, value)
              traverse_nodes(value, &block)
            end
          elsif node.is_a?(Array)
            node.each_with_index do |item, index|
              # Provide the index to uniquely identify each element
              traverse_nodes(item) { |key, value| yield("#{key}[#{index}]", value) }
            end
          end
        end

        # Find the correct processor based on the key using the registered processor config
        def find_processor_for(key, _value)
          @processor_config.processor_for(key) # Return the processor class, not an instance
        end
      end
    end
  end
end
