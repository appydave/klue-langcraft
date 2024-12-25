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
        attr_reader :klue_data
        attr_accessor :klue_processed

        def initialize
          klue_reset
        end

        def process(input: nil, input_file: nil, output_file: nil)
          klue_reset
          klue_validate_input_arguments(input, input_file)
          klue_input_content = klue_input_content(input, input_file)

          @klue_processed = true
          instance_eval(klue_input_content)

          klue_write_output(output_file) if output_file
          klue_data
        end

        def method_missing(method_name, *args, &block)
          raise "You must call 'process' before using other methods" unless @klue_processed

          key = method_name
          value = klue_process_args(args, block)

          if @klue_data[key]
            @klue_data[key] = [@klue_data[key]] unless @klue_data[key].is_a?(Array)
            @klue_data[key] << value
          else
            @klue_data[key] = value
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          @klue_processed || super
        end

        def klue_process_args(args, block)
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
          klue_data = positional_args.each_with_index.to_h { |arg, index| [:"p#{index + 1}", arg] }

          # Merge named parameters after positional ones
          klue_data.merge!(named_args)

          # Handling a nested block
          if block
            interpreter = Interpreter.new
            interpreter.instance_variable_set(:@klue_processed, true) # Set @klue_processed to true for nested interpreter
            interpreter.instance_eval(&block)
            klue_data.merge!(interpreter.klue_data)
          end

          klue_data.empty? ? nil : klue_data
        end

        private

        def klue_reset
          @klue_data = {}
          @klue_processed = false
        end

        def klue_validate_input_arguments(input, input_file)
          raise ArgumentError, 'Either input or input_file must be provided' unless input || input_file
          raise ArgumentError, 'Both input and input_file cannot be provided' if input && input_file
        end

        def klue_input_content(input, input_file)
          input_file ? File.read(input_file) : input
        end

        def klue_write_output(output_file)
          output_path = klue_output_path(output_file)
          File.write(output_path, JSON.pretty_generate(data))
        end

        def klue_output_path(output_file)
          if Pathname.new(output_file).absolute?
            output_file
          else
            File.join(File.dirname(output_file), File.basename(output_file))
          end
        end
      end
    end
  end
end
