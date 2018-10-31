# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrPurchaseOrder
      class Edit
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_purchase_order, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Back to Purchase Orders',
                                  url: '/list/mr_purchase_orders',
                                  style: :back_button)
              section.add_control(control_type: :link,
                                  text: 'Manage Costs',
                                  url: "/list/mr_purchase_order_costs/with_params?key=standard&purchase_order_id=#{id}",
                                  style: :button,
                                  behaviour: :popup)
              if ui_rule.form_object.purchase_order_number.nil?
                section.add_control(control_type: :link,
                                    text: 'Approve Purchase Order',
                                    url: "/pack_material/replenish/mr_purchase_orders/#{id}/approve_purchase_order",
                                    style: :button)
              end
            end

            page.section do |section|
              section.show_border!
              section.form do |form|
                form.action "/pack_material/replenish/mr_purchase_orders/#{id}"
                form.method :update
                form.row do |row|
                  row.column do |col|
                    col.add_field :purchase_order_number
                    col.add_field :supplier_party_role_id
                    col.add_field :supplier_name
                    col.add_field :supplier_erp_number
                    col.add_field :mr_delivery_term_id
                    col.add_field :mr_vat_type_id
                  end

                  row.column do |col|
                    col.add_field :purchase_account_code
                    col.add_field :fin_object_code
                    col.add_field :valid_until
                    col.add_field :delivery_address_id
                  end
                end
              end
            end

            page.section do |section|
              section.show_border!
              section.row do |row|
                row.column do |col|
                  col.add_control(control_type: :link,
                                  text: 'New Item',
                                  url: "/pack_material/replenish/mr_purchase_orders/#{id}/mr_purchase_order_items/new",
                                  style: :button,
                                  behaviour: :popup,
                                  css_class: 'mb1')
                  col.add_grid('po_items',
                               "/list/mr_purchase_order_items/grid?key=standard&purchase_order_id=#{id}",
                               height: 8,
                               caption: 'Purchase Order Line Items')
                end
              end
            end
          end
          layout
        end
      end
    end
  end
end
