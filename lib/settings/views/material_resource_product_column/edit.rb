# frozen_string_literal: true

module Settings
  module PackMaterialProducts
    module MaterialResourceProductColumn
      class Edit
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:material_resource_product_column, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/settings/pack_material_products/material_resource_product_columns/#{id}"
              form.remote!
              form.method :update
              form.add_field :material_resource_domain_id
              form.add_field :column_name
              form.add_field :group_name
              form.add_field :is_variant_column
            end
          end

          layout
        end
      end
    end
  end
end
