# frozen_string_literal: true

module PackMaterial
  module MaterialResource
    module MatresProductVariant
      class Edit
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:matres_product_variant, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/material_resource/material_resource_product_variants/#{id}"
              form.remote!
              form.method :update
              form.add_field :product_variant_id
              form.add_field :product_variant_table_name
              form.add_field :product_variant_number
              form.add_field :old_product_code
              form.add_field :supplier_lead_time
              form.add_field :minimum_stock_level
              form.add_field :re_order_stock_level
            end
          end

          layout
        end
      end
    end
  end
end
