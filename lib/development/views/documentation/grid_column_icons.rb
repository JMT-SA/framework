# frozen_string_literal: true

module Development
  module Documentation
    class GridColumnIcons
      def self.call # rubocop:disable Metrics/AbcSize
        # get list of app_icons
        filenames = Dir.children(File.join(ENV['ROOT'], 'public/app_icons')).map { |f| f.delete_suffix('.svg') }.sort

        # css = File.read(File.join(ENV['ROOT'], 'public/css/jquery.contextMenu.min.css'))
        # icons = css.split(/\.context-menu-icon-/).select { |s| s.include?(':before{content') }.map { |s| s[0, s.index(':before')] }

        layout = Crossbeams::Layout::Page.build({}) do |page| # rubocop:disable Metrics/BlockLength
          page.section do |section|
            section.add_text 'Grid icons for icon columns', wrapper: :h1
            section.add_control(control_type: :link, text: 'Back to documentation home', url: '/developer_documentation/start.adoc', style: :back_button)
            section.add_control(control_type: :link, text: 'Back to icon documentation', url: '/developer_documentation/icons.adoc', style: :back_button)
            section.add_control(control_type: :link, text: 'Grid icon list', url: '/development/grid_icons', style: :button)
            section.add_control(control_type: :link, text: 'Layout icon list', url: '/development/layout_icons', style: :button)
            section.add_text <<~HTML
              These are the icons that are available to use in grids with icon columns.<br>
              <ol><li>The column must be a string with its formatter set to <em>iconFormatter</em>.</li>
              <li>The row's value can be null or <code>icon_name[,colour][,level]</code> - where <em>colour</em> and <em>level</em> are optional.</li>
              <li><em>icon_name</em> must match one of the names below.</li>
              <li><em>colour</em> can be any valid CSS colour value. Defaults to grey.</li>
              <li><em>level</em> must be an integer. This sets the indent of the icon. Defaults to zero (or if the row has a column named "level", that value will be used).</li>
              </ol>
            HTML
            section.add_text <<~HTML, syntax: :sql
              -- Example SQL
              SELECT CASE WHEN approved THEN 'star-full,red' WHEN completed THEN 'circle' ELSE NULL END AS icon,
                     CASE WHEN approved THEN 2 WHEN completed THEN 1 ELSE 0 END AS level
              FROM a_table
            HTML
            section.add_text <<~HTML
              <ul class="list pl0">
                #{filenames.map { |i| "<li class='pa2'><img class='cbl-icon mr2' src='/app_icons/#{i}.svg'> #{i}</li>" }.join}
              </ul>
            HTML
          end
        end

        layout
      end
    end
  end
end
