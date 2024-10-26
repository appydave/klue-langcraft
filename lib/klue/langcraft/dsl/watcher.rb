# frozen_string_literal: true

require 'listen'

module Klue
  module Langcraft
    module DSL
      class Watcher
        def initialize(directories, **options)
          @directories = directories.map { |dir| File.expand_path(dir) }
          @options = options
          @klue_runner = Klue::Langcraft::DSL::KlueRunner.new
          @extensions = options[:extensions] || ['.klue']
        end

        def start
          extension_regex = Regexp.union(@extensions.map { |ext| /#{Regexp.escape(ext)}$/ })
          listener = Listen.to(*@directories, only: extension_regex) do |modified, added, _removed|
            (modified + added).each do |file|
              process_file(file)
            end
          end

          log_info('Watching directories', @directories.join(', '))
          log_info('Watching file extensions', @extensions.join(', '))
          log_info('Create basic JSON', @options[:create_basic_json])
          log_info('Create enhanced JSON', @options[:create_enhanced_json])
          log_info('Webhook URL', @options[:webhook_url])
          log_info('Log level', @options[:log_level])

          listener.start
          sleep
        end

        private

        def process_file(file)
          log_info('Processing file', file)

          options = @options.dup
          options[:input_file] = file
          options[:basic_output_file] = file.sub(/#{File.extname(file)}$/, '.json') if @options[:create_basic_json]
          options[:enhanced_output_file] = file.sub(/#{File.extname(file)}$/, '.enhanced.json') if @options[:create_enhanced_json]

          @klue_runner.run(
            input_file: options[:input_file],
            basic_output_file: options[:basic_output_file],
            enhanced_output_file: options[:enhanced_output_file],
            webhook_url: options[:webhook_url],
            log_level: options[:log_level]
          )
        rescue StandardError => e
          log_error('Error processing file', "#{file}: #{e.message}")
        end

        def log_info(label, value)
          puts "#{label.ljust(30)}: #{value}" if %i[info detailed].include?(@options[:log_level])
        end

        def log_error(label, value)
          puts "#{label.ljust(30)}: #{value}"
        end
      end
    end
  end
end
