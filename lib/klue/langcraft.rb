# frozen_string_literal: true

require 'klue/langcraft/version'

module Klue
  module Langcraft
    # raise Klue::Langcraft::Error, 'Sample message'
    Error = Class.new(StandardError)

    # Your code goes here...
  end
end

if ENV.fetch('KLUE_DEBUG', 'false').downcase == 'true'
  namespace = 'KlueLangcraft::Version'
  file_path = $LOADED_FEATURES.find { |f| f.include?('klue-langcraft/version') }
  version   = KlueLangcraft::VERSION.ljust(9)
  puts "#{namespace.ljust(35)} : #{version.ljust(9)} : #{file_path}"
end
