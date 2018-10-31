# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrPurchaseOrder
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:mr_purchase_order, :show, id: id)
          rules   = ui_rule.compile

          role_id = ui_rule.form_object.supplier_party_role_id
          delivery_address = MasterfilesApp::PartyRepo.new.addresses_for_party(party_role_id: role_id)

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :purchase_order_number
              form.add_field :supplier_name
              form.add_field :supplier_erp_number
              form.add_field :mr_delivery_term_id
              form.add_field :mr_vat_type_id
              form.add_field :purchase_account_code
              form.add_field :fin_object_code
              form.add_field :valid_until
              # form.add_field :delivery_address
              form.add_address delivery_address
            end
          end

          layout
        end
      end
    end
  end
end
