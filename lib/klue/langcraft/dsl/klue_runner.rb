# frozen_string_literal: true

module Klue
  module Langcraft
    module DSL
      # KlueRunner handles the processing of DSL input data
      # It manages the execution of various processors and the output of processed data
      class KlueRunner
        attr_reader :interpreter, :pipeline, :webhook

        def initialize
          @interpreter = Klue::Langcraft::DSL::Interpreter.new
          @pipeline = Klue::Langcraft::DSL::ProcessDataPipeline.new(Klue::Langcraft::DSL::ProcessMatcher.new)
          @webhook = Klue::Langcraft::DSL::Webhook.new
        end

        # Run the KlueRunner with the given input data
        # @param input [String] The input data to process
        # @param input_file [String] The input file to process (input data and file are mutually exclusive)
        # @param basic_output_file [String] The output file to write the processed data, this file is before any processing
        # @param enhanced_output_file [String] The output file to write the processed data, this file is after processing
        def run(
          input: nil,
          input_file: nil,
          basic_output_file: nil,
          enhanced_output_file: nil,
          webhook_url: nil,
          log_level: :none
        )
          @log_level = log_level

          log_info('Processing input')
          data = interpreter.process(input: input, input_file: input_file, output_file: basic_output_file)
          log_detailed('Interpreter output:', data)

          log_info('Executing pipeline - enhance')
          enhanced_data = pipeline.execute(data)
          log_detailed('Enhanced output:', enhanced_data)

          if enhanced_output_file
            log_info("Writing enhanced output to file: #{enhanced_output_file}")
            @pipeline.write_output(enhanced_data, enhanced_output_file)
          end

          if webhook_url
            log_info("Delivering data to webhook: #{webhook_url}")
            @webhook.deliver(webhook_url, enhanced_data)
          end

          log_info('Processing complete')
        end

        private

        def log_info(message)
          puts message if %i[info detailed].include?(@log_level)
        end

        def log_detailed(message, data)
          return unless @log_level == :detailed

          puts message
          pp data
        end
      end
    end
  end
end
