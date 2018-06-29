# frozen_string_literal: true

module PackMaterial
  module Config
    module MatresType
      class Unit
        def self.call(parent_id, form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:matres_type, :add_unit, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/config/material_resource_types/#{parent_id}/unit"
              form.remote! if remote
              form.add_field :unit_of_measure
              form.add_field :other
            end
          end

          layout
        end
      end
    end
  end
end
