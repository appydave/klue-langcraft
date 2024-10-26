# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'
require 'listen'
require 'pry'

require 'appydave/tools'

require 'klue/langcraft/version'
require 'klue/langcraft/dsl/processor_config'

ProcessorConfigDefault = Klue::Langcraft::DSL::ProcessorConfig.new

require 'klue/langcraft/dsl/processors/processor'
require 'klue/langcraft/dsl/processors/file_collector_processor'
require 'klue/langcraft/dsl/processors/full_name_processor'
require 'klue/langcraft/dsl/interpreter'
require 'klue/langcraft/dsl/process_matcher'
require 'klue/langcraft/dsl/process_data_pipeline'
require 'klue/langcraft/dsl/webhook'
require 'klue/langcraft/dsl/watcher'
require 'klue/langcraft/dsl/klue_runner'

module Klue
  module Langcraft
    # raise Klue::Langcraft::Error, 'Sample message'
    Error = Class.new(StandardError)

    # Your code goes here...
  end
end

if ENV.fetch('KLUE_DEBUG', 'false').downcase == 'true'
  namespace = 'Klue::Langcraft::Version'
  file_path = $LOADED_FEATURES.find { |f| f.include?('klue-langcraft/version') }
  version   = Klue::Langcraft::VERSION.ljust(9)
  puts "#{namespace.ljust(35)} : #{version.ljust(9)} : #{file_path}"
end
