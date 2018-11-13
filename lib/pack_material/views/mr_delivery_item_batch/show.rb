# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrDeliveryItemBatch
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:mr_delivery_item_batch, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :internal_batch_number
              form.add_field :client_batch_number
              form.add_field :quantity_on_note
              form.add_field :quantity_received
            end
          end

          layout
        end
      end
    end
  end
end
