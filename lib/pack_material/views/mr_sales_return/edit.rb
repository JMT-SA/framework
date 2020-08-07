# frozen_string_literal: true

module PackMaterial
  module Dispatch
    module MrSalesReturn
      class Edit
        def self.call(id, form_values: nil, form_errors: nil)
          ui_rule = UiRules::Compiler.new(:mr_sales_return, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'Edit Sales Return'
              form.action "/pack_material/dispatch/mr_sales_returns/#{id}"
              form.remote!
              form.method :update
              form.add_field :mr_sales_order_id
              form.add_field :issue_transaction_id
              form.add_field :created_by
              form.add_field :remarks
              form.add_field :sales_return_number
            end
          end

          layout
        end
      end
    end
  end
end
