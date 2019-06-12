# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrDeliveryItem
      class New
        def self.call(parent_id, item_id, form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_delivery_item, :new, parent_id: parent_id, item_id: item_id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/replenish/mr_deliveries/#{parent_id}/mr_delivery_items"
              form.remote! if remote
              form.add_field :mr_delivery_id
              form.add_field :mr_purchase_order_item_id
              form.add_field :mr_product_variant_id
              form.add_field :quantity_on_note
              form.add_field :quantity_over_supplied
              form.add_field :quantity_under_supplied
              form.add_field :quantity_received
              form.add_field :invoiced_unit_price
              form.add_field :remarks
            end
          end

          layout
        end
      end
    end
  end
end
