module Development
  module Grids
    module List
      class List
        def self.call
          layout = Crossbeams::Layout::Page.build do |page|
            page.section do |section|
              section.caption = 'Maintain grid lists'
              section.hide_caption = false
              section.add_grid 'yml_list', '/development/grids/lists/grid'
            end
          end

          layout
        end
      end
    end
  end
end
