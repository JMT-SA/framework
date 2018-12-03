# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrDeliveryItem
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:mr_delivery_item, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :mr_product_variant_code
              form.add_field :quantity_on_note
              form.add_field :quantity_over_supplied
              form.add_field :quantity_under_supplied
              form.add_field :quantity_received
              form.add_field :invoiced_unit_price
              form.add_field :remarks
            end
          end

          layout
        end
      end
    end
  end
end
