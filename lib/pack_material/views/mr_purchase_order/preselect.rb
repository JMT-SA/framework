# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrPurchaseOrder
      class Preselect
        def self.call(form_values: nil, form_errors: nil)
          ui_rule = UiRules::Compiler.new(:mr_purchase_order, :preselect, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/pack_material/replenish/mr_purchase_orders/new'
              form.add_field :supplier_id
            end
          end

          layout
        end
      end
    end
  end
end
