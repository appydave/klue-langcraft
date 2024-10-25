# frozen_string_literal: true

module Klue
  module Langcraft
    # Parser class
    class Parser
      def initialize(tokens, schema)
        @tokens = tokens
        @schema = schema
        @position = 0
      end

      def parse
        parse_node(@schema['definition'])
      end

      private

      def parse_node(node_schema)
        node = { 'name' => node_schema['name'], 'params' => {}, 'children' => [] }

        # Parse parameters
        node['params'] = parse_params(node_schema['params'])

        # If node has child nodes
        if node_schema['nodes']
          # Expect 'do'
          expect('do')

          # Parse child nodes
          while peek != 'end'
            child_node_schema = match_node_schema(node_schema['nodes'])
            node['children'] << parse_node(child_node_schema)
          end

          expect('end')
        end

        node
      end

      def parse_params(params_schema)
        params = {}
        params_schema.each do |param_schema|
          # Extract parameter based on its type
          params[param_schema['name']] = extract_param(param_schema)
        end
        params
      end

      def extract_param(param_schema)
        # Implement extraction logic based on param_schema['type']
      end

      def expect(expected_token)
        actual_token = next_token
        return unless actual_token != expected_token

        raise "Expected '#{expected_token}', got '#{actual_token}'"
      end

      def next_token
        token = @tokens[@position]
        @position += 1
        token
      end

      def peek
        @tokens[@position]
      end

      def match_node_schema(nodes_schema)
        current_token = peek
        nodes_schema.find { |ns| ns['name'] == current_token } || raise("Unknown node '#{current_token}'")
      end
    end
  end
end
