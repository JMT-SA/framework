# frozen_string_literal: true

module PackMaterial
  module Transactions
    module MrBulkStockAdjustment
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:mr_bulk_stock_adjustment, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New Bulk Stock Adjustment'
              form.action '/pack_material/transactions/mr_bulk_stock_adjustments'
              form.remote! if remote
              form.add_field :business_process_id
              form.add_field :ref_no
            end
          end

          layout
        end
      end
    end
  end
end
