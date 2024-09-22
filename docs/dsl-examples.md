# DSL Examples

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
