# frozen_string_literal: true

module PackMaterial
  module Dispatch
    module SalesReturnCost
      class New
        def self.call(parent_id, form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:sales_return_cost, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New Refund'
              form.action "/pack_material/sales_returns/mr_sales_returns/#{parent_id}/sales_return_costs"
              form.remote! if remote
              form.add_field :mr_sales_return_id
              form.add_field :mr_cost_type_id
              form.add_field :amount
            end
          end

          layout
        end
      end
    end
  end
end
