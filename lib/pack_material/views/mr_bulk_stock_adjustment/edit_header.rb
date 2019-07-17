# frozen_string_literal: true

module PackMaterial
  module Transactions
    module MrBulkStockAdjustment
      class EditHeader
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_bulk_stock_adjustment, :edit_header, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors

            page.form do |form|
              form.action "/pack_material/transactions/mr_bulk_stock_adjustments/#{id}"
              form.method :update
              form.remote!
              form.add_field :create_transaction_id
              form.add_field :destroy_transaction_id
              form.add_field :stock_adjustment_number
              form.add_field :ref_no
              # form.add_field :is_stock_take
              form.add_field :approved
              form.add_field :completed
              form.add_field :sku_numbers_list
              form.add_field :location_list
            end
          end

          layout
        end
      end
    end
  end
end
