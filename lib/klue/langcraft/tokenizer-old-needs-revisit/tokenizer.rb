# frozen_string_literal: true

module Klue
  module Langcraft
    # Tokenizer class
    class Tokenizer
      attr_reader :tokens

      def initialize(code)
        @code = code
        @tokens = []
      end

      def tokenize
        # Implement logic to convert code into tokens
        # Handle strings, symbols, keywords, and delimiters
      end
    end
  end
end
