# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrDelivery
      class Edit
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
          ui_rule = UiRules::Compiler.new(:mr_delivery, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Back to Deliveries',
                                  url: '/list/mr_deliveries',
                                  style: :back_button)
              if rules[:can_verify]
                section.add_control(control_type: :link,
                                    text: 'Verify Delivery',
                                    url: "/pack_material/replenish/mr_deliveries/#{id}/verify",
                                    prompt: true,
                                    style: :button)
              end
              if rules[:can_add_invoice] || rules[:can_complete_invoice]
                cost_url = rules[:invoice_completed] ? '/list/mr_purchase_invoice_costs_show' : '/list/mr_purchase_invoice_costs'
                section.add_control(control_type: :link,
                                    text: 'Manage Costs',
                                    url: cost_url + "/with_params?key=standard&mr_delivery_id=#{id}",
                                    style: :button,
                                    behaviour: :popup)
                url = rules[:invoice_completed]
                section.add_control(control_type: :link,
                                    text: 'Invoice Info',
                                    url: "/pack_material/replenish/mr_deliveries/#{id}/invoice",
                                    style: :button,
                                    behaviour: :popup)
              end
              section.add_control(control_type: :link,
                                  text: 'Complete Purchase Invoice',
                                  url: "/pack_material/replenish/mr_deliveries/#{id}/complete_invoice",
                                  prompt: true,
                                  id: 'mr_delivery_complete_button',
                                  visible: rules[:can_complete_invoice],
                                  style: :button)
            end

            page.section do |section|
              section.show_border!
              section.add_caption 'Delivery'
              section.form do |form|
                form.action "/pack_material/replenish/mr_deliveries/#{id}"
                form.method :update unless rules[:is_verified]
                form.view_only! if rules[:is_verified]
                form.no_submit! if rules[:is_verified]
                form.row do |row|
                  row.column do |col|
                    col.add_field :delivery_number
                    col.add_field :transporter
                    col.add_field :status
                    col.add_field :transporter_party_role_id
                    col.add_field :receipt_location_id
                    col.add_field :driver_name
                  end

                  row.column do |col|
                    col.add_field :client_delivery_ref_number
                    col.add_field :vehicle_registration
                    col.add_text po_totals(rules)
                  end
                end
              end
            end

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Goods Returned Note report',
                                  url: "/pack_material/reports/goods_returned/#{id}",
                                  loading_window: true,
                                  style: :button)
              section.add_control(control_type: :link,
                                  text: 'Delivery Received Note report',
                                  url: "/pack_material/reports/delivery_received/#{id}",
                                  loading_window: true,
                                  style: :button)
            end

            page.section do |section|
              section.show_border!
              section.row do |row|
                row.column do |col|
                  unless rules[:is_verified]
                    col.add_control(control_type: :link,
                                    text: 'New Item',
                                    url: "/pack_material/replenish/mr_deliveries/#{id}/mr_delivery_items/preselect",
                                    style: :button,
                                    behaviour: :popup,
                                    grid_id: 'del_items',
                                    css_class: 'mb1')
                    col.add_grid('del_items',
                                 "/list/mr_delivery_items/grid?key=standard&delivery_id=#{id}",
                                 height: 8,
                                 caption: 'Delivery Line Items')
                  end
                  if (rules[:can_add_invoice] || rules[:can_complete_invoice]) && !rules[:invoice_completed]
                    col.add_grid('del_items',
                                 "/list/mr_delivery_items_edit_unit_prices/grid?key=standard&delivery_id=#{id}",
                                 height: 8,
                                 caption: 'Delivery Line Items')
                  end
                  if rules[:invoice_completed]
                    col.add_grid('del_items',
                                 "/list/mr_delivery_items_show/grid?key=standard&delivery_id=#{id}",
                                 height: 8,
                                 caption: 'Delivery Line Items')
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
            <tr><th class="tr pr2">Sub-total</th><td class="tr"><span id="del_totals_subtotal">#{rules[:del_sub_totals][:subtotal]}</span></td></tr>
            <tr><th class="tr pr2">Costs</th><td class="tr"><span id="del_totals_costs">#{rules[:del_sub_totals][:costs]}</span></td></tr>
            <tr><th class="tr pr2">Total</th><td class="tr b bb bt"><span id="del_totals_total">#{rules[:del_sub_totals][:total]}</span></td></tr>
            </tbody></table>
            </div>
          HTML
        end
      end
    end
  end
end
