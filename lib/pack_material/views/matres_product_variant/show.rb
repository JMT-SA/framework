# frozen_string_literal: true

module PackMaterial
  module MaterialResource
    module MatresProductVariant
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:matres_product_variant, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
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
