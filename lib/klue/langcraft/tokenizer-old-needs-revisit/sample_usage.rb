# frozen_string_literal: true

# Read DSL code from file
dsl_code = File.read('workflow_dsl.rb')

# Tokenize the DSL code
tokenizer = Tokenizer.new(dsl_code)
tokenizer.tokenize

# Parse tokens into an AST
parser = Parser.new(tokenizer.tokens, schema)
ast = parser.parse

# Output the AST
puts ast.inspect
