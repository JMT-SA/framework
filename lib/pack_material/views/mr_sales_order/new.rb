# frozen_string_literal: true

module PackMaterial
  module Dispatch
    module MrSalesOrder
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:mr_sales_order, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New Sales Order'
              form.action '/pack_material/sales/mr_sales_orders'
              form.remote! if remote
              form.add_field :customer_party_role_id
            end
          end

          layout
        end
      end
    end
  end
end
