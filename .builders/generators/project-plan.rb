KManager.action :project_plan do
  action do

    DrawioDsl::Drawio
      .init(k_builder, on_exist: :write, on_action: :execute)
      .diagram(rounded: 1, glass: 1)
      .page('In progress', theme: :style_03, margin_left: 0, margin_top: 0) do
        grid_layout(y: 190, direction: :horizontal, grid_h: 80, grid_w: 320, wrap_at: 3, grid: 0)

        todo(title: 'Migrate from alpine to svelte, vue or react')
        # todo(title: '')
      end
      .page('To Do', theme: :style_02, margin_left: 0, margin_top: 0) do
        grid_layout(y:90, direction: :horizontal, grid_h: 80, grid_w: 320, wrap_at: 3, grid: 0)

        todo(title: 'Add guideline documentation')
        todo(title: 'Docs as Code sample DSL')
        todo(title: 'Agent as Code sample DSL')
        todo(title: 'Poly as Code sample DSL')
        todo(title: 'DSLs as Code sample DSL')
        todo(title: 'Voice as Code sample DSL')
        todo(title: 'Data as Code sample DSL')
        todo(title: 'Chart Design as Code sample DSL')
        todo(title: 'Video as Code sample DSL')
        todo(title: 'Image as Code sample DSL')

      end      
      .page('Done', theme: :style_06, margin_left: 0, margin_top: 0) do

        grid_layout(y:90, direction: :horizontal, grid_h: 80, grid_w: 320, wrap_at: 3, grid: 0)

        todo(title: 'Setup project with CI/CD, tests, linting, basic doumentation, semantic versioning')
      end
      .cd(:docs)
      .save('project-plan/project.drawio')
      .export_svg('project-plan/project_in_progress', page: 1)
      .export_svg('project-plan/project_todo'       , page: 2)
      .export_svg('project-plan/project_done'       , page: 3)
  end
end
