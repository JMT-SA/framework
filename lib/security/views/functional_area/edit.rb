module Security
  module FunctionalAreas
    module FunctionalArea
      class Edit
        def self.call(id, form_values = nil, form_errors = nil)
          ui_rule = UiRules::Compiler.new(:functional_area, :edit, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/security/functional_areas/functional_areas/#{id}"
              form.remote!
              form.method :update
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
