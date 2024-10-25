# frozen_string_literal: true

# ChatReferences:
# - https://chatgpt.com/c/6719840b-c72c-8002-bbc2-bbd95fd98d31

module Klue
  module Langcraft
    module DSL
      # Interpreter class for processing and interpreting DSL input
      #
      # This class is responsible for handling method calls, processing arguments,
      # and managing the overall interpretation of the DSL input. It also provides
      # methods for processing input and output, as well as converting the data
      # to hash and JSON formats.
      class Interpreter
        attr_reader :data
        attr_accessor :processed

        def initialize
          @data = {}
          @processed = false
        end

        def process(input: nil, input_file: nil, output_file: nil)
          validate_input_arguments(input, input_file)
          input_content = input_content(input, input_file)

          @processed = true
          instance_eval(input_content)

          write_output(output_file) if output_file
          data
        end

        def method_missing(method_name, *args, &block)
          raise "You must call 'process' before using other methods" unless @processed

          key = method_name
          value = process_args(args, block)

          if @data[key]
            @data[key] = [@data[key]] unless @data[key].is_a?(Array)
            @data[key] << value
          else
            @data[key] = value
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          @processed || super
        end

        def process_args(args, block)
          positional_args = []
          named_args = {}

          # Handling positional and named parameters separately
          args.each do |arg|
            if arg.is_a?(Hash)
              named_args.merge!(arg)
            else
              positional_args << arg
            end
          end

          # Assign positional parameters generically
          data = positional_args.each_with_index.to_h { |arg, index| [:"p#{index + 1}", arg] }

          # Merge named parameters after positional ones
          data.merge!(named_args)

          # Handling a nested block
          if block
            interpreter = Interpreter.new
            interpreter.instance_variable_set(:@processed, true) # Set @processed to true for nested interpreter
            interpreter.instance_eval(&block)
            data.merge!(interpreter.data)
          end

          data.empty? ? nil : data
        end

        private

        def validate_input_arguments(input, input_file)
          raise ArgumentError, 'Either input or input_file must be provided' unless input || input_file
          raise ArgumentError, 'Both input and input_file cannot be provided' if input && input_file
        end

        def input_content(input, input_file)
          input_file ? File.read(input_file) : input
        end

        def write_output(output_file)
          output_path = get_output_path(output_file)
          File.write(output_path, JSON.pretty_generate(data))
        end

        def get_output_path(output_file)
          if Pathname.new(output_file).absolute?
            output_file
          else
            File.join(File.dirname(output_file), File.basename(output_file))
          end
        end

        # Convert to JSON
        def to_json(*_args)
          @data.to_json
        end
      end
    end
  end
end
