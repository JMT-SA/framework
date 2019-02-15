# frozen_string_literal: true

module PackMaterial
  module Transactions
    module MrInventoryTransaction
      class New
        def self.call(id, type: nil, form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_inventory_transaction, :new, form_values: form_values, type: type, sku_location_id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'Add Stock'
              form.action "/pack_material/transactions/adhoc_stock_transactions/#{id}?type=#{type}"
              form.remote! if remote
              form.add_field :sku_number
              form.add_field :business_process_id
              form.add_field :to_location_id
              form.add_field :vehicle_id
              form.add_field :ref_no
              form.add_field :quantity
              form.add_field :is_adhoc
            end
          end

          layout
        end
      end
    end
  end
end
