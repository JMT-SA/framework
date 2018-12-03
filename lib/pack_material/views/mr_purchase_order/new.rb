# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrPurchaseOrder
      class New
        def self.call(supplier_id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_purchase_order, :new, supplier_id: supplier_id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/pack_material/replenish/mr_purchase_orders'
              form.add_field :supplier_id
              form.add_field :supplier_name
              form.add_field :supplier_erp_number
              form.add_field :mr_delivery_term_id
              form.add_field :supplier_party_role_id
              form.add_field :mr_vat_type_id
              form.add_field :delivery_address_id
              form.add_field :purchase_account_code
              form.add_field :fin_object_code
              form.add_field :valid_until
              # form.add_field :purchase_order_number
            end
          end

          layout
        end
      end
    end
  end
end
