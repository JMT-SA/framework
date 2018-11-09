# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrDelivery
      class Edit
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_delivery, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/replenish/mr_deliveries/#{id}"
              form.remote!
              form.method :update
              form.add_field :delivery_number
              form.add_field :transporter_party_role_id
              form.add_field :driver_name
              form.add_field :client_delivery_ref_number
              form.add_field :vehicle_registration
              form.add_field :supplier_invoice_ref_number
            end
          end

          layout
        end
      end
    end
  end
end
