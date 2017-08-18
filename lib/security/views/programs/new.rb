module Security
  module FunctionalAreas
    module Programs
      class New
        def self.call(id, form_values = nil, form_errors = nil)

          rules = { fields: {
            functional_area_id: { renderer: :hidden },
            program_name: { },
            active: { renderer: :checkbox },
          }, name: 'program'.freeze }

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object(OpenStruct.new(functional_area_id: id,
                                            program_name: nil,
                                            active: true))
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/security/functional_areas/programs/create'
              form.add_field :functional_area_id
              form.add_field :program_name
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
