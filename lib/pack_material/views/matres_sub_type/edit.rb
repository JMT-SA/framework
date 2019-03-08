# frozen_string_literal: true

module PackMaterial
  module Config
    module MatresSubType
      class Edit
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:matres_sub_type, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/config/material_resource_sub_types/#{id}"
              form.remote!
              form.method :update
              form.add_field :material_resource_type_id
              form.add_field :inventory_uom_id
              form.add_field :sub_type_name
              form.add_field :short_code
              form.add_field :product_code_separator
              form.add_field :has_suppliers
              form.add_field :has_marketers
              form.add_field :has_retailers
            end
          end

          layout
        end
      end
    end
  end
end
