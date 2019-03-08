# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrPurchaseOrderItem
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:mr_purchase_order_item, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :mr_purchase_order_id
              form.add_field :mr_product_variant_id
              form.add_field :inventory_uom_id
              form.add_field :quantity_required
              form.add_field :unit_price
            end
          end

          layout
        end
      end
    end
  end
end
