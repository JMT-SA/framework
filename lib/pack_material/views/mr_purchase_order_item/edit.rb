# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrPurchaseOrderItem
      class Edit
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_purchase_order_item, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/replenish/mr_purchase_order_items/#{id}"
              form.remote!
              form.method :update
              form.add_field :mr_purchase_order_id
              form.add_field :mr_product_variant_id
              form.add_field :mr_product_variant
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
