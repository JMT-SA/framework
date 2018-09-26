# frozen_string_literal: true

module PackMaterial
  module MaterialResource
    module MatresProductVariantPartyRole
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:matres_product_variant_party_role, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :material_resource_product_variant_id
              form.add_field :product_variant_code
              form.add_field :product_variant_number
              form.add_field :party_name
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
