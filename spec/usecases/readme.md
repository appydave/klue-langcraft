# DSL Use Cases

DSL ideas are listed and documented in the usecases folder

Note: Most DSLs follow a clean format that would be readable to any Domain Expert in the field and should be real simple to read.

DSL as code is different from the rest in that it is a DSL for writing other DSLs and structurally it can be a little confusing, it is not a good DSL to pattern off when creating other DSLs

## `dsl-as-code`

This DSL is used to build other DSLs quickly

Key Features of This DSL:

- **Repeatable nodes:** You define nodes that can be repeated, such as setting and prompt, and the repeatability is enforced with the repeat: true attribute.
- **Flexible Parameters:** Each node can accept various types of parameters (positional, optional, named, splats, double splats), allowing you to model complex relationships between nodes.
- **Node Ownership:** In cases where nodes are repeatable and grouped (like settings and prompts), the container property can be used to denote that these belong to a plural version of the node, such as a settings container holding multiple setting nodes.
- **Hierarchical Structure:** This allows you to define parent-child relationships (e.g., section containing steps, which in turn contain inputs and prompts).

## `project-plan`

This DSL is used to generate todo, done, and backlog lists for project planning.

Key Features of This DSL:

- **Page Structure:** Defines multiple pages (e.g., In Progress, To Do, Done) with customizable themes and layouts.
- **Grid Layout:** Allows specification of grid layout for organizing todo items.
- **Todo Items:** Supports adding multiple todo items to each page.
- **Export Functionality:** Includes the ability to export pages to different formats (e.g., SVG).

## `agent-as-code`

This DSL is used to define AI agents and their workflows.

Key Features of This DSL:

- **Agent Structure:** Defines an agent with a name, description, settings, and actions.
- **Prompts:** Allows definition of multiple prompts with names and content.
- **Workflow Sections:** Supports organizing the agent's workflow into sections.
- **Steps:** Each section can contain multiple steps with inputs, prompts, and outputs.
- **Actions:** Defines actions that can be performed with the agent.

Each DSL is contained in its own subfolder with relevant files and examples.