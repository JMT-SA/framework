# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrPurchaseInvoiceCost
      class New
        def self.call(parent_id, form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_purchase_invoice_cost, :new, parent_id: parent_id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New Purchase Invoice Cost'
              form.action "/pack_material/replenish/mr_deliveries/#{parent_id}/mr_purchase_invoice_costs"
              form.remote! if remote
              form.add_field :mr_cost_type_id
              form.add_field :mr_delivery_id
              form.add_field :amount
            end
          end

          layout
        end
      end
    end
  end
end
