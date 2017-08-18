module Security
  module FunctionalAreas
    module FunctionalAreas
      class Edit
        def self.call(id, form_values = nil, form_errors = nil)

          this_repo = FunctionalAreaRepo.new
          obj     = this_repo.find(id)
          rules = { fields: {
            functional_area_name: { },
            active: { renderer: :checkbox },
          } }

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object obj
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/security/functional_areas/functional_areas/#{id}/update"
              form.remote!
              form.add_field :functional_area_name
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end

