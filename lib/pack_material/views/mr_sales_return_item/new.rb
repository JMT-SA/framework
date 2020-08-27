# frozen_string_literal: true

module PackMaterial
  module Dispatch
    module MrSalesReturnItem
      class New
        def self.call(parent_id, form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:mr_sales_return_item, :new, form_values: form_values, parent_id: parent_id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.add_notice 'No more items available for this sales order', notice_type: :info if rules[:zero_options]
            page.form do |form|
              form.caption 'New Mr Sales Return Item'
              form.action "/pack_material/sales_returns/mr_sales_returns/#{parent_id}/mr_sales_return_items"
              form.remote! if remote
              form.add_field :mr_sales_order_item_id
            end
          end

          layout
        end
      end
    end
  end
end
