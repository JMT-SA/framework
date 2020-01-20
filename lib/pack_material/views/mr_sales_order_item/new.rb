# frozen_string_literal: true

module PackMaterial
  module Dispatch
    module MrSalesOrderItem
      class New
        def self.call(parent_id, form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_sales_order_item, :new, form_values: form_values, parent_id: parent_id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New Item'
              form.action "/pack_material/sales/mr_sales_orders/#{parent_id}/mr_sales_order_items"
              form.remote! if remote
              form.add_field :mr_sales_order_id
              form.add_field :mr_product_variant_lookup
              form.add_field :mr_product_variant_id
              form.add_field :mr_product_variant_code
              form.add_field :mr_product_variant_number
              form.add_field :quantity_required
              form.add_field :unit_price
              # form.add_field :remarks
            end
          end

          layout
        end
      end
    end
  end
end
