# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrDeliveryItem
      class Preselect
        def self.call(parent_id, form_values: nil, form_errors: nil, remote: true, purchase_order_id: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_delivery_item, :preselect, parent_id: parent_id, purchase_order_id: purchase_order_id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/replenish/mr_deliveries/#{parent_id}/mr_delivery_items/new"
              form.remote! if remote
              form.add_field :purchase_order_id
              form.add_field :mr_delivery_id
              form.add_field :mr_purchase_order_item_id
            end

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Done',
                                  url: "/pack_material/replenish/mr_deliveries/#{parent_id}/mr_delivery_items/done",
                                  style: :button)
            end
          end

          layout
        end
      end
    end
  end
end
