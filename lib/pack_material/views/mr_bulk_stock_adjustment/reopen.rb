# frozen_string_literal: true

module PackMaterial
  module Transactions
    module MrBulkStockAdjustment
      class Complete
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:mr_bulk_stock_adjustment, :reopen, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.caption 'Reopen Mr Bulk Stock Adjustment'
              form.action "/pack_material/transactions/mr_bulk_stock_adjustments/#{id}/reopen"
              form.remote!
              form.submit_captions 'Reopen'
              form.add_text 'Are you sure you want to reopen this mr_bulk_stock_adjustment for editing?', wrapper: :h3
              form.add_field :stock_adjustment_number
              form.add_field :sku_numbers
              form.add_field :location_long_codes
              form.add_field :active
              form.add_field :is_stock_take
              form.add_field :approved_by
              form.add_field :approved_on
              form.add_field :completed
              form.add_field :uncompleted_on
              form.add_field :approved
            end
          end

          layout
        end
      end
    end
  end
end
