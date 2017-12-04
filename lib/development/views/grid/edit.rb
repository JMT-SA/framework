module Development
  module Grids
    module List
      class Edit
        def self.call(list_file, list_def)
          layout = Crossbeams::Layout::Page.build do |page|
            page.section do |section|
              section.caption = list_def[:dataminer_definition]
              section.hide_caption = false
              # section.add_text list_def.inspect
              section.add_grid 'actions', "/development/grids/lists/grid_actions/#{list_file}", height: 12, caption: 'Actions'
            end
            page.section do |section|
              section.add_grid 'page_controls', "/development/grids/lists/grid_page_controls/#{list_file}", height: 8, caption: 'Page Controls'
            end
            page.section do |section|
              section.add_grid 'multiselects', "/development/grids/lists/grid_multiselects/#{list_file}", height: 8, caption: 'Multiselect settings'
              section.add_grid 'conditions', "/development/grids/lists/grid_conditions/#{list_file}", height: 8, caption: 'Conditions'
            end
          end

          layout
        end
      end
    end
  end
end
