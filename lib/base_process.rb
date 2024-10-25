# frozen_string_literal: true

# file: lib/base_process.rb

class BaseProcess
  attr_reader :key

  def initialize(key)
    @key = key
    puts "one: Initialized with key: #{@key}"
  end

  def deep_match(input, predicate)
    puts "two: Starting deep_match with input: #{input.class}"

    matches = []
    puts 'three: Initialized empty matches array'

    # If the current input is a Hash, iterate over each key-value pair
    if input.is_a?(Hash)
      puts 'four: Input is a Hash, iterating over each key-value pair'

      input.each do |key, value|
        puts "five: Checking key: #{key}, value: #{value.class}"

        # If the value matches the predicate, add it to matches
        if predicate.call(key, value)
          puts "six: Predicate matched for key: #{key}, adding to matches"
          matches << value
          puts "seven: Current matches: #{matches}"
        end

        # Continue searching deeper within the value
        matches.concat(deep_match(value, predicate))
        puts "eight: After deeper match, current matches: #{matches}"
      end

    # If the input is an Array, iterate over each item
    elsif input.is_a?(Array)
      puts 'nine: Input is an Array, iterating over each item'

      input.each do |item|
        puts "ten: Checking item: #{item.class}"

        # Continue searching within each item of the array
        matches.concat(deep_match(item, predicate))
        puts "eleven: After deeper match in Array, current matches: #{matches}"
      end
    end

    puts "twelve: Returning matches: #{matches}"
    matches
  end
end
