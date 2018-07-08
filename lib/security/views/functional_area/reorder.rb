module Security
  module FunctionalAreas
    module FunctionalArea
      class Reorder
        def self.call(id)
          this_repo = SecurityApp::MenuRepo.new
          progs = this_repo.programs_for_select(id)

          layout = Crossbeams::Layout::Page.build do |page|
            page.form do |form|
              form.action "/security/functional_areas/functional_areas/#{id}/save_reorder"
              form.remote!
              form.add_text 'Drag and drop to re-order. Press submit to save the new order.'
              form.add_sortable_list('p', progs)
            end
          end

          layout
        end
      end
    end
  end
end
