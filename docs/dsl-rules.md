# DSL Rules

The DSL using ruby like syntax that maps paramaters and values in fashion similar to the Ruby programming language.

## Data Types in DSLs

DSLs can use various types of data as input and provide flexibility in handling different kinds of values. Below are the main data types supported:

- **Strings:** Represent textual data and are enclosed in quotes. They are typically used for descriptive content or text-based parameters.
- **Symbols:** Identifiers often used for keys or labels in configuration. Symbols are concise and unique, making them ideal for representing options or identifiers.
- **Booleans:** Represent true/false values and are useful for toggling features or conditions within the DSL.
- **Integers:** Whole numbers without fractions, often used for quantities, counts, or IDs.
- **Floats:** Numbers that include decimal points, used when more precise values are required, such as for time durations or percentages.

These data types allow the DSL to handle a wide variety of input values, making it versatile for different use cases and configurations.

Note: Data types are currently only cosmetic, everything will get stored as a string internally, but we might put in some validation that can at least let us know if we've got the wrong sort of data provided.


## DSL argument rules

In Ruby, parameters (or "arguments") come in various types such as positional, optional, splat (*), and keyword arguments (**). 
Each parameter type follows specific conventions, and the Ruby language uses distinct terms for each. 
Below is an overview of these types and their corresponding metadata fields.

### Methods and Arguements

#### 1. Positional Parameters
- **Description**: These are the most common type of parameters. They are passed in the exact order defined in the method signature.
- **Ruby Example**: `def method(a, b)`
- **Metadata Fields**:
  - `type`: positional
  - `name`: a (or the parameter name)
- **Inferred Fields**:
  - `required`: true

```ruby
param :a, type: :positional               # required: true
param :b, type: :positional               # required: true
```


#### 2. Optional Parameters
- **Description**: These are positional parameters with default values, making them optional.
- **Ruby Example**: `def method(a = 1)`
- **Metadata Fields**:
  - `type`: positional
  - `name`: a
  - `default_value`: 1
- **Inferred Fields**:
  - `required`: false

```ruby
param :a, type: :positional, default: 1   # required: false
```

#### 3. Splat Parameters (*)
- **Description**: The splat operator `*` captures any number of additional positional arguments into an array.
- **Ruby Example**: `def method(*args)`
- **Metadata Fields**:
  - `type`: splat
  - `name`: args
- **Inferred Fields**:
  - `required`: false
  - `variadic`: true

```ruby
param :args, type: :splat                 # required: false, variadic: true
```

#### 4. Keyword Parameters
- **Description**: Keyword arguments are named arguments passed as a hash or individual key-value pairs. They can be required or optional.
- **Ruby Example**: `def method(a:, b: 1)`
- **For required keyword argument**:
  - **Metadata Fields**:
      - `type`: keyword
      - `name`: a
  - **Inferred Fields**:
    - `required`: true
- **For optional keyword argument**:
  - **Metadata Fields**:
    - `type`: keyword
    - `name`: b
    - `default_value`: 1
  - **Inferred Fields**:
    - `required`: false

```ruby
param :a, type: :keyword                  # required: true
param :b, type: :keyword, default: 1      # required: true
```


#### 5. Double Splat Parameters (**)
- **Description**: The double splat operator `**` captures any number of additional keyword arguments into a hash.
- **Ruby Example**: `def method(**opts)`
- **Metadata Fields**:
  - `type`: double_splat
  - `name`: opts
- **Inferred Fields**:
  - `required`: false
  - `variadic`: true

```ruby
param :opts, type: :double_splat           # required: false, variadic: true
```

#### Block Paramaters

The idea of ruby block parameters have been deprectated, instead the syntax has been retained for containers, see below.

## DSL Containers

Containers represent a named block that can take parameters and contain aditional nested elements.

They follow usage that is similar in concept to an XML element, in that they have a name, then can take paramaters (aka attributes) and then can be self closing.

The container will be represented as a `do ... end` when hosting child containers
The container can also be self closing, in which case there is no `do ... end`, there is just an element with zero or more parameters followed by a newline.

The root containers will be called `definition`, all other containers will be known as `node`

### Rules

These rules should be observed when dealing with different parameters and blocks

**Required vs Optional Parameters:**

- **Positional required parameters**: Defined without a default value.
- **Optional positional parameters**: Have default values or are represented with splat (`*`).
- **Required keyword arguments**: Must be passed explicitly unless a default value is provided.
- **Optional keyword arguments**: Have default values or can be omitted.

### Order and constraints

A container can take parameters based on the defined styles, but they must follow an order and adhere to constraints.

**Order/Construction:**

1. Declarative parameters (if present, the method name acts as the first positional parameter)
2. Required positional parameters
3. Optional positional parameters
4. Splat parameters, zero or one
5. Required keyword parameters
6. Optional keyword parameters
7. Double splat parameters, zero or one

**Constraints:**

1. Declarative parameters, if present, replace the first positional parameter, and no additional required positional parameters can come before it.
2. Required positional parameters must come before any optional positional parameters.
3. The splat parameter, if present, must come after all positional parameters (required and optional).
4. Keyword parameters (both required and optional) must come after all positional and splat parameters.
5. The double splat parameter, if present, must be the last parameter.
6. You can't have more than one splat or double splat parameter in a container.
7. Once you start using keyword parameters, you can't use positional parameters anymore in that container.

## Examples

The following examples will build on top of one another to create an Agent as Code DSL designed for Agent Workflows.

The example workflow will ben implementation of the agent as code for YouTube Launch Optimization.

### Root Node (#1).

The root node for a DSL is named `definition`, it behaves like any other `node` accept that you provide the DSL name.

An agentic workflow might take a name and optional description.

```ruby
# Sample DSL
workflow :youtube_launch_optimizer, 'Optimize the video publishing for YouTube Titles, Descriptions, Thumbnails and social content' do
end
```

```ruby
# DSL Definition
definition :workflow do
  param :name, type: :positional
  param :description, type: :positional, default: nil
end
```

### Root Node (#2).

An agentic workflow might take a name only and use a child node for description using a self closing syntax.

```ruby
# Sample DSL
workflow :youtube_launch_optimizer do
  description 'Optimize the video publishing for YouTube Titles, Descriptions, Thumbnails and social content'
end
```

```ruby
# DSL Definition
definition :workflow do
  param :name, type: :positional
  node :description do
    param :description, type: :positional
  end
end
```

### Single Node with List (#3)

Here we have a single node called settings with a list of setting that contains a key and a value.
Notice `repeat: true` is used to indicate that the setting is a repeatable element.

```ruby
# Sample DSL

workflow :youtube_launch_optimizer do
  settings do
    setting :prompt_path, 'prompts/youtube/launch_optimizer'
    setting :default_llm, :gpt4o
  end
end
```

```ruby
# DSL Definition
definition :workflow do
  param :name, type: :positional
  node :settings do
    node :setting, repeat: true do
      param :key, type: :positional
      param :value, type: :positional
    end
  end
end
```

### Single Node with list - declaritve syntax  (#4)

Like before, we have a single node called settings with a list of setting that contains a key and a value.
This time the you can use the method name as the first paramater value because it is of type declarative.
This can make some DSL usage a little easier to understand

```ruby
# Sample DSL

workflow :youtube_launch_optimizer do
  settings do
    prompt_path 'prompts/youtube/launch_optimizer'
    default_llm :gpt4o
  end
end
```

```ruby
# DSL Definition
definition :workflow do
  param :name, type: :positional
  node :settings do
    node :setting, repeat: true do
      param :key, type: :declaritive      # the method name typed in will be come the value for the key paramater
      param :value, type: :positional
    end
  end
end
```
