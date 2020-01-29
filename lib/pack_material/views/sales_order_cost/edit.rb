# frozen_string_literal: true

module PackMaterial
  module Dispatch
    module SalesOrderCost
      class Edit
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:sales_order_cost, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'Edit Sales Order Cost'
              form.action "/pack_material/sales/sales_order_costs/#{id}"
              form.remote!
              form.method :update
              form.add_field :mr_sales_order_id
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
