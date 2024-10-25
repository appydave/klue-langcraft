# frozen_string_literal: true

# file: lib/base_process.rb

class BaseProcess
  attr_reader :key

  def initialize(key)
    @key = key
  end

  def deep_match(input, predicate)
    matches = []

    # If the current input is a Hash, iterate over each key-value pair
    if input.is_a?(Hash)

      input.each do |key, value|

        # If the value matches the predicate, add it to matches
        if predicate.call(key, value)
          matches << value
        end

        # Continue searching deeper within the value
        matches.concat(deep_match(value, predicate))
      end

    # If the input is an Array, iterate over each item
    elsif input.is_a?(Array)

      input.each do |item|

        # Continue searching within each item of the array
        matches.concat(deep_match(item, predicate))
      end
    end

    matches
  end
end
