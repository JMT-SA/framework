# frozen_string_literal: true

module PackMaterial
  module MaterialResource
    module MatresProductVariantPartyRole
      class New
        def self.call(parent_id, type, form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:matres_product_variant_party_role, :new, parent_id: parent_id, type: type, form_values: form_values)
          rules   = ui_rule.compile

          supplier = type == AppConst::ROLE_SUPPLIER.downcase
          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/material_resource/material_resource_product_variants/#{parent_id}/material_resource_product_variant_party_roles?type=#{type}"
              form.remote! if remote
              form.add_field :material_resource_product_variant_id
              form.add_field :product_variant_code
              form.add_field :product_variant_number
              form.add_field :supplier_id
              form.add_field :customer_id
              form.add_field :party_stock_code
              form.add_field :supplier_lead_time if supplier
              form.add_field :is_preferred_supplier if supplier
            end
          end

          layout
        end
      end
    end
  end
end
