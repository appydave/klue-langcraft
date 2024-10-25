# frozen_string_literal: true

# file: lib/process_file_collector.rb

class ProcessFileCollector < BaseProcess
  def initialize(key)
    super
    @found = nil
    # @matcher = ->(key, value) { key.to_s == 'file_collector' && value.is_a?(Hash) }
    @matcher = lambda do |key, value|
      if key.to_s == 'file_collector'
        if value.is_a?(Array)
          value.any? { |v| v.is_a?(Hash) }
        else
          value.is_a?(Hash)
        end
      else
        false
      end
    end
  end

  def match?(input)
    @found = deep_match(input, @matcher)
    !@found.empty?
  end

  def execute(_input)
    # Iterate over each `file_collector` found and process individually
    results = {}

    @found.each do |data|
      next unless data.is_a?(Hash)

      # Extract the `as` key if present
      as_key = data['as']

      working_directory = File.expand_path(data['root'])

      options = Appydave::Tools::GptContext::Options.new(
        working_directory: working_directory,
        include_patterns: extract_patterns(data.dig('files', 'include')),
        exclude_patterns: extract_patterns(data.dig('files', 'exclude')),
        format: 'json',
        line_limit: data['line_length']
      )

      collector = Appydave::Tools::GptContext::FileCollector.new(options)
      json = collector.build

      # Structuring the result under `process-data` with `as` as key
      result_data = {
        type: 'file_collector',
        data: {
          working_directory: working_directory,
          files: JSON.parse(json)
        }
      }

      # If `as` key exists, use it to store under process-data with that identifier
      if as_key
        results[as_key] = result_data
      else
        # Generate a unique key if no `as` key is defined
        unique_key = "file_collector_#{results.size + 1}"
        results[unique_key] = result_data
      end
    end

    results
  rescue SyntaxError, NameError, NoMethodError => e
    puts "Ruby evaluation error in ProcessFileCollector: #{e.message}"
    puts "Error occurred at: #{e.backtrace.first}"
    {}
  rescue StandardError => e
    puts "Unexpected error in ProcessFileCollector: #{e.message}"
    puts e.backtrace.join("\n")
    {}
  end

  private

  def extract_patterns(files_data)
    if files_data.is_a?(Hash)
      [files_data['param1']]
    elsif files_data.is_a?(Array)
      files_data.map { |entry| entry['param1'] }
    else
      []
    end
  end
end
