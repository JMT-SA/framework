# frozen_string_literal: true

module PackMaterial
  module Transactions
    module MrBulkStockAdjustment
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:mr_bulk_stock_adjustment, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :stock_adjustment_number
              form.add_field :ref_no
              # form.add_field :active
              form.add_field :is_stock_take
              form.add_field :completed
              form.add_field :approved
              form.add_field :signed_off
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
