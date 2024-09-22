# Brief for creating the Parser, Tokenizer and Parsing our first DSL

# 1. Parsing Libraries in Ruby

Here are three Ruby parsing libraries with their pros and cons:

### Parslet
**Pros:**
- Pure Ruby library for constructing parsers using parsing expression grammars (PEG).
- Intuitive and readable grammar definitions embedded in Ruby code.
- Actively maintained with compatibility for modern Ruby versions.

**Cons:**
- Can be slower for large inputs due to backtracking.
- Verbose grammars can become complex for intricate DSLs.

### Racc
**Pros:**
- LALR(1) parser generator that comes standard with Ruby.
- Generates fast parsers suitable for complex grammars.
- Actively maintained as part of the Ruby language.

**Cons:**
- Steeper learning curve with Yacc-like syntax.
- Less intuitive for those unfamiliar with parser generators.

### Treetop
**Pros:**
- Provides a powerful parsing DSL and supports PEG.
- Clean syntax with grammars defined in separate files.
- Memoization for improved parsing performance.

**Cons:**
- Less active development; may not be updated for recent Ruby versions.
- Potential compatibility issues with newer Ruby releases.

**Note:** Based on maintenance and compatibility, Parslet and Racc are more suitable for your needs.

---

# 2. Converting the DSL Definition into JSON

Transforming your DSL definition into JSON will facilitate parsing and validation. Here's how your DSL definition can be represented in JSON:

```json
{
  "definition": {
    "name": "workflow",
    "params": [
      {
        "name": "name",
        "type": "positional"
      }
    ],
    "nodes": [
      {
        "name": "description",
        "params": [
          {
            "name": "description",
            "type": "positional"
          }
        ]
      },
      {
        "name": "settings",
        "nodes": [
          {
            "name": "setting",
            "repeat": true,
            "params": [
              {
                "name": "key",
                "type": "declarative"
              },
              {
                "name": "value",
                "type": "positional"
              }
            ]
          }
        ]
      },
      {
        "name": "prompts",
        "nodes": [
          {
            "name": "prompt",
            "repeat": true,
            "params": [
              {
                "name": "key",
                "type": "positional"
              },
              {
                "name": "content",
                "type": "named",
                "default": ""
              }
            ]
          }
        ]
      },
      {
        "name": "section",
        "repeat": true,
        "params": [
          {
            "name": "name",
            "type": "positional"
          }
        ],
        "nodes": [
          {
            "name": "step",
            "repeat": true,
            "params": [
              {
                "name": "key",
                "type": "positional"
              }
            ],
            "nodes": [
              {
                "name": "input",
                "repeat": true,
                "params": [
                  {
                    "name": "key",
                    "type": "positional"
                  }
                ]
              },
              {
                "name": "prompt",
                "params": [
                  {
                    "name": "key",
                    "type": "positional"
                  }
                ]
              },
              {
                "name": "output",
                "repeat": true,
                "params": [
                  {
                    "name": "key",
                    "type": "positional"
                  }
                ]
              }
            ]
          }
        ]
      },
      {
        "name": "actions",
        "nodes": [
          {
            "name": "save",
            "params": []
          },
          {
            "name": "save_json",
            "params": [
              {
                "name": "path",
                "type": "positional"
              }
            ]
          }
        ]
      }
    ]
  }
}
```

# 3. Writing a Parser in Raw Ruby

Given the simplicity and hierarchical nature of your DSL, you can write a custom parser in Ruby without external libraries. Below is an outline of how to approach this:

### Step 1: Tokenization
- Create a tokenizer that reads the DSL code and breaks it down into tokens (keywords, symbols, identifiers, strings, etc.).

```ruby
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
```

### Step 2: Parsing
- Use recursive descent parsing to process tokens according to the rules defined in your JSON schema.

```ruby
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
    if actual_token != expected_token
      raise "Expected '#{expected_token}', got '#{actual_token}'"
    end
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
```

### Step 3: Building the Abstract Syntax Tree (AST)
- As you parse, construct an AST that captures both the structural elements and their associated data.

#### Example Usage:

```ruby
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
```

### Considerations:

#### Parsing Parameters:
- Implement the `parse_params` method to handle different parameter types:
  - **Positional Parameters:** Split `params_str` by commas or spaces, and assign values in order.
  - **Declarative Parameters:** Use the node name as the parameter value.
  - **Named Parameters:** Look for `key: value` pairs.

#### Handling Repetition:
- For nodes with `repeat: true`, allow multiple instances by continuing to parse matching nodes until none are found.

### Advantages:
- **Simplicity:** Direct control over parsing logic tailored to your DSL.
- **No Dependencies:** Eliminates issues with outdated libraries.
- **Customizable:** Easy to modify as your DSL evolves.

### Challenges:
- **Complexity Management:** As your DSL grows, the parser logic may become more complex.
- **Testing:** Thorough testing is needed to ensure reliability.
- **Performance:** May need optimization for large DSL files.

---

# 5. Additional Considerations

While your immediate focus is on building the engine, keep in mind future integration with tools like IDEs:

- **Abstract Syntax Tree (AST):** A well-structured AST can facilitate features like syntax highlighting and code completion.
- **Language Server Protocol (LSP):** If you decide to provide IDE support, structuring your parser to output data compatible with LSP can be beneficial.
- **Extensibility:** Designing your parser and data structures with future enhancements in mind can save time later.

---

# 6. Conclusion

Creating a custom parser in Ruby without external libraries is feasible for your DSL, especially given its hierarchical and relatively simple structure. This approach offers:

- **Control and Flexibility:** Tailor the parser to your specific needs without external constraints.
- **Understanding:** Deepens your knowledge of parsing techniques and the inner workings of your DSL.
- **Maintainability:** Avoids dependency issues associated with outdated gems.

### Next Steps:
1. **Implement the Parser:** Start coding the parser using the outlined approaches.
2. **Test with Examples:** Use your existing DSL examples to validate the parser's functionality.
3. **Iterate:** Refine the parser based on testing, adding error handling and edge case management as needed.
   - **Parameter Types:** Implement logic for different parameter types (positional, declarative, named, etc.).
   - **Repeating Nodes:** Handle nodes with `repeat: true` by looping until no more matching nodes are found.
   - **Error Handling:** Include meaningful error messages for unexpected tokens or structure violations.
   - **Whitespace and Comments:** Strip out or ignore to simplify tokenization.

---

# 4. Writing the Parser Without External Libraries

You can implement the parser using Ruby's built-in capabilities, focusing on string manipulation and control structures.

### Simplified Parser Example:
