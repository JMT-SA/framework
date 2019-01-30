# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrDelivery
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:mr_delivery, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :delivery_number
              form.add_field :status
              form.add_field :transporter
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
