# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrDeliveryItemBatch
      class New
        def self.call(parent_id, form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_delivery_item_batch, :new, parent_id: parent_id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/replenish/mr_delivery_items/#{parent_id}/mr_delivery_item_batches"
              form.remote! if remote
              form.add_field :mr_delivery_item_id
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
