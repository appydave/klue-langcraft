#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'klue/langcraft'
require 'optparse'

# CLI class for the Klue Langcraft application.
# This class handles command-line interactions, parsing options,
# and executing the appropriate commands for processing files
# or watching directories.
class CLI
  def initialize
    @commands = {
      'process' => method(:process_files),
      'watch' => method(:watch_files)
    }
  end

  def run
    if ARGV.empty?
      print_help
      exit
    end

    command, *args = ARGV
    if @commands.key?(command)
      @commands[command].call(args)
    else
      puts "Unknown command: #{command}"
      print_help
    end
  end

  private

  def process_files(args)
    options = {}
    parser = OptionParser.new do |opts|
      opts.banner = 'Usage: langcraft process [options]'

      opts.on('-i', '--input FILE', 'Input file (required)') do |file|
        options[:input] = file
      end

      opts.on('-b', '--basic-output FILE', 'Output file') do |file|
        options[:basic_output] = file
      end

      opts.on('-e', '--enhanced-output FILE', 'Output file') do |file|
        options[:enhanced_output] = file
      end

      opts.on('-u', '--webhook-url URL', 'Webhook URL') do |url|
        options[:webhook_url] = url
      end

      opts.on('-d', '--debug LEVEL', %i[none info detailed], 'Debug level (none, info, detailed)') do |level|
        options[:debug] = level
      end

      opts.on('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end

    parser.parse!(args)

    if validate_options(options)
      run_klue_runner(options)
    else
      print_usage(parser)
    end
  end

  def validate_options(options)
    if options[:input].nil?
      puts 'Error: Input file is required.'
      false
    else
      true
    end
  end

  def run_klue_runner(options)
    klue_runner = Klue::Langcraft::DSL::KlueRunner.new
    klue_runner.run(
      input_file: options[:input],
      basic_output_file: options[:basic_output],
      enhanced_output_file: options[:enhanced_output],
      webhook_url: options[:webhook_url],
      debug: options[:debug] || :none
    )
  rescue StandardError => e
    puts "Error: #{e.message}"
    exit 1
  end

  def print_usage(parser)
    puts 'Error: Invalid or missing options.'
    puts
    puts parser
    exit 1
  end

  def watch_files(args)
    options = {
      directories: [],
      create_basic_json: false,
      create_enhanced_json: false,
      log_level: :info,
      webhook_url: nil,
      extensions: ['.klue'] # Default extension
    }
    OptionParser.new do |opts|
      opts.banner = 'Usage: server watch [options]'

      opts.on('-w', '--watch-directory DIRECTORY', 'Directory to watch (can be specified multiple times)') do |dir|
        options[:directories] << File.expand_path(dir) # Expand the path here
      end

      opts.on('-f', '--flags TYPE', 'Set processing flags (none, basic, enhanced, all)') do |type|
        types = type.split(',').map(&:strip).map(&:downcase)
        options[:create_basic_json] = types.include?('basic') || types.include?('all')
        options[:create_enhanced_json] = types.include?('enhanced') || types.include?('all')
      end

      opts.on('-l', '--log-level LEVEL', %i[none info detailed], 'Log level (none, info, detailed)') do |level|
        options[:log_level] = level
      end

      opts.on('-u', '--webhook-url URL', 'Webhook URL') do |url|
        options[:webhook_url] = url
      end

      opts.on('-e', '--extensions EXT1,EXT2,...', Array, 'File extensions to watch (default: .klue)') do |exts|
        options[:extensions] = exts.map { |ext| ext.start_with?('.') ? ext : ".#{ext}" }
      end

      opts.on('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end.parse!(args)

    # If no directories were specified, use the current directory
    options[:directories] = [Dir.pwd] if options[:directories].empty?

    # Ensure all directories are expanded
    options[:directories].map! { |dir| File.expand_path(dir) }

    Klue::Langcraft::DSL::Watcher.new(
      options[:directories],
      create_basic_json: options[:create_basic_json],
      create_enhanced_json: options[:create_enhanced_json],
      log_level: options[:log_level],
      webhook_url: options[:webhook_url],
      extensions: options[:extensions]
    ).start
  end

  def print_help
    puts 'Klue Langcraft Server'
    puts 'Usage: server [command] [options]'
    puts ''
    puts 'Commands:'
    puts '  process  Process a single file'
    puts '  watch    Watch directories for changes'
    puts ''
    puts "Run 'server [command] --help' for more information on a command."
  end
end

# Run the CLI
CLI.new.run
