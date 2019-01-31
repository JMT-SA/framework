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
              cost_url = rules[:show_only] ? '/list/mr_purchase_order_costs_show' : '/list/mr_purchase_order_costs'
              section.add_control(control_type: :link,
                                  text: 'Manage Costs',
                                  url: cost_url + "/with_params?key=standard&purchase_order_id=#{id}",
                                  style: :button,
                                  behaviour: :popup)
              if rules[:can_approve] && !rules[:show_only]
                section.add_control(control_type: :link,
                                    text: 'Approve Purchase Order',
                                    url: "/pack_material/replenish/mr_purchase_orders/#{id}/approve_purchase_order",
                                    prompt: true,
                                    style: :button)
              end
            end

            page.section do |section|
              section.show_border!
              section.add_caption 'Purchase Order'
              section.form do |form|
                form.action "/pack_material/replenish/mr_purchase_orders/#{id}"
                form.method :update unless rules[:show_only]
                form.view_only! if rules[:show_only]
                form.no_submit!
                form.row do |row|
                  row.column do |col|
                    col.add_field :purchase_order_number
                    col.add_field :status
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
                    col.add_text po_totals(rules)
                  end
                end
              end
            end

            page.section do |section|
              section.show_border!
              section.row do |row|
                row.column do |col|
                  if rules[:show_only]
                    col.add_grid('po_items',
                                 "/list/mr_purchase_order_items_show/grid?key=standard&purchase_order_id=#{id}",
                                 height: 8,
                                 caption: 'Purchase Order Line Items')
                  else
                    col.add_control(control_type: :link,
                                    text: 'New Item',
                                    url: "/pack_material/replenish/mr_purchase_orders/#{id}/mr_purchase_order_items/new",
                                    style: :button,
                                    behaviour: :popup,
                                    grid_id: 'po_items',
                                    css_class: 'mb1')
                    col.add_grid('po_items',
                                 "/list/mr_purchase_order_items/grid?key=standard&purchase_order_id=#{id}",
                                 height: 8,
                                 caption: 'Purchase Order Line Items')
                  end
                end
              end
            end
          end
          layout
        end

        def self.po_totals(rules)
          <<~HTML
            <div class="fr">
            <table><tbody>
            <tr><th class="tr pr2">Sub-total</th><td class="tr"><span id="po_totals_subtotal">#{rules[:sub_totals][:subtotal]}</span></td></tr>
            <tr><th class="tr pr2">Costs</th><td class="tr"><span id="po_totals_costs">#{rules[:sub_totals][:costs]}</span></td></tr>
            <tr><th class="tr pr2">VAT</th><td class="tr"><span id="po_totals_vat">#{rules[:sub_totals][:vat]}</span></td></tr>
            <tr><th class="tr pr2">Total</th><td class="tr b bb bt"><span id="po_totals_total">#{rules[:sub_totals][:total]}</span></td></tr>
            </tbody></table>
            </div>
          HTML
        end
      end
    end
  end
end
