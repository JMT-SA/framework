# frozen_string_literal: true

module PackMaterial
  module Transactions
    module MrBulkStockAdjustmentItem
      class New
        def self.call(parent_id, form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_bulk_stock_adjustment_item, :new, form_values: form_values, parent_id: parent_id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New Bulk Stock Adjustment Item'
              form.action "/pack_material/transactions/mr_bulk_stock_adjustments/#{parent_id}/mr_bulk_stock_adjustment_items"
              form.remote! if remote
              form.form_id 'new_bsa_item'
              form.add_field :mr_bulk_stock_adjustment_id
              form.add_field :sku_location_lookup
              form.add_field :mr_sku_id
              form.add_field :location_id
              form.add_field :list_items

              form.submit_captions 'Add', 'Adding'
            end
            page.section do |section|
              section.add_control(control_type: :link, text: 'Done', url: "/pack_material/transactions/mr_bulk_stock_adjustments/#{parent_id}/edit", style: :button)
            end
          end

          layout
        end
      end
    end
  end
end
