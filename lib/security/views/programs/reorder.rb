module Security
  module FunctionalAreas
    module Programs
      class Reorder
        def self.call(id)

          this_repo = ProgramRepo.new
          progfuncs = this_repo.program_functions_for_select(id)

          layout = Crossbeams::Layout::Page.build do |page|
            page.form do |form|
              form.action "/security/functional_areas/programs/#{id}/save_reorder"
              form.remote!
              form.add_text 'Drag and drop to re-order. Press submit to save the new order.'
              form.add_sortable_list('pf', progfuncs)
            end
          end

          layout
        end
      end
    end
  end
end
