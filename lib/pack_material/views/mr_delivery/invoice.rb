# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrDelivery
      class Invoice
        def self.call(id, form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_delivery, :edit_invoice, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors

            page.form do |form|
              form.action "/pack_material/replenish/mr_deliveries/#{id}/invoice"
              form.method :update
              form.remote! if remote
              form.view_only! if rules[:invoice_completed]
              form.no_submit! if rules[:invoice_completed]
              form.add_field :supplier_invoice_ref_number
              form.add_field :supplier_invoice_date
              form.add_field :erp_purchase_order_number if rules[:invoice_completed]
              form.add_field :erp_purchase_invoice_number if rules[:invoice_completed]
            end
          end

          layout
        end
      end
    end
  end
end
