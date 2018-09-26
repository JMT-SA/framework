# frozen_string_literal: true

module PackMaterial
  module MaterialResource
    module MatresProductVariantPartyRole
      class Edit
        def self.call(id, type, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:matres_product_variant_party_role, :edit, id: id, type: type, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/material_resource/material_resource_product_variant_party_roles/#{id}"
              form.remote!
              form.method :update
              form.add_field :material_resource_product_variant_id
              form.add_field :product_variant_code
              form.add_field :product_variant_number
              form.add_field :supplier_id
              form.add_field :customer_id
              form.add_field :party_stock_code
              form.add_field :supplier_lead_time
              form.add_field :is_preferred_supplier
            end
          end

          layout
        end
      end
    end
  end
end
