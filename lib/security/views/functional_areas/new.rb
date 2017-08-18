module Security
  module FunctionalAreas
    module FunctionalAreas
      class New
        def self.call(form_values = nil, form_errors = nil)
          rules = { fields: {
            functional_area_name: { },
            active: { renderer: :checkbox },
          }, name: 'functional_area'.freeze }

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object(OpenStruct.new(functional_area_name: nil,
                             active: true))
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/security/functional_areas/functional_areas/create'
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
