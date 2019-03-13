# frozen_string_literal: true

module PackMaterial
  module Transactions
    module MrBulkStockAdjustmentItem
      class Edit
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_bulk_stock_adjustment_item, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'Edit Mr Bulk Stock Adjustment Item'
              form.action "/pack_material/transactions/mr_bulk_stock_adjustment_items/#{id}"
              form.remote!
              form.method :update
              form.add_field :mr_bulk_stock_adjustment_id
              form.add_field :mr_sku_location_id
              form.add_field :sku_number
              form.add_field :product_variant_number
              form.add_field :mr_type_name
              form.add_field :mr_sub_type_name
              form.add_field :product_variant_code
              form.add_field :location_long_code
              form.add_field :inventory_uom_code
              form.add_field :scan_to_location_long_code
              form.add_field :system_quantity
              form.add_field :actual_quantity
              form.add_field :stock_take_complete
            end
          end

          layout
        end
      end
    end
  end
end
