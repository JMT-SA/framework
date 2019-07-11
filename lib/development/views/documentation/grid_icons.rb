# frozen_string_literal: true

module Development
  module Documentation
    class GridIcons
      def self.call # rubocop:disable Metrics/AbcSize
        css = File.read(File.join(ENV['ROOT'], 'public/css/jquery.contextMenu.min.css'))
        icons = css.split(/\.context-menu-icon-/).select { |s| s.include?(':before{content') }.map { |s| s[0, s.index(':before')] }

        layout = Crossbeams::Layout::Page.build({}) do |page|
          page.section do |section|
            section.add_text 'Grid icons for action list menu items', wrapper: :h1
            section.add_control(control_type: :link, text: 'Back to documentation home', url: '/developer_documentation/start.adoc', style: :back_button)
            section.add_control(control_type: :link, text: 'Back to icon documentation', url: '/developer_documentation/icons.adoc', style: :back_button)
            section.add_control(control_type: :link, text: 'Layout icon list', url: '/development/layout_icons', style: :button)
            section.add_control(control_type: :link, text: 'Grid column icon list', url: '/development/grid_column_icons', style: :button)
            section.add_text <<~HTML, wrapper: :p
              These are the icons that are available to use for grid menu items.<br>
              In a list or search <code>.yml</code> file you would write <code>:icon: add</code>.<br>
              In <code>Crossbeams::DataGrid::ColumnDefiner</code> DSL you would include <code>icon: 'add'</code> in an action's hash.
            HTML
            section.add_text <<~HTML
              <ul class="list pl0">
              #{icons.map { |i| "<li class='context-menu-icon context-menu-item context-menu-icon-#{i}' style='user-select:text;'>#{i}</li>" }.join}
              </ul>
            HTML
          end
        end

        layout
      end
    end
  end
end
