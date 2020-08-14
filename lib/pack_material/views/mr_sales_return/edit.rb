# frozen_string_literal: true

module PackMaterial
  module Dispatch
    module MrSalesReturn
      class Edit # rubocop:disable Metrics/ClassLength
        def self.call(id, user, form_values: nil, form_errors: nil, interactor: nil) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          ui_rule = UiRules::Compiler.new(:mr_sales_return, :edit, id: id, form_values: form_values, current_user: user, interactor: interactor)
          rules   = ui_rule.compile

          cannot_edit = rules[:completed]

          layout = Crossbeams::Layout::Page.build(rules) do |page| # rubocop:disable Metrics/BlockLength
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Back to Sales Returns',
                                  url: "/list/mr_sales_returns/with_params?key=#{rules[:completed] ? 'completed' : 'incomplete'}",
                                  style: :back_button)
              section.add_control(control_type: :link,
                                  text: 'Verify Sales Return',
                                  url: "/pack_material/sales_returns/mr_sales_returns/#{id}/verify_sales_return",
                                  prompt: true,
                                  id: 'mr_sales_returns_verify_button',
                                  visible: rules[:can_verify_sales_return],
                                  style: :button)
              cost_url = rules[:completed] ? '/list/sales_return_costs_show' : '/list/sales_return_costs'
              section.add_control(control_type: :link,
                                  text: 'Manage Refunds',
                                  url: cost_url + "/with_params?key=standard&mr_sales_return_id=#{id}",
                                  style: :button,
                                  visible: rules[:can_verify_sales_return] || rules[:can_complete_sales_return],
                                  behaviour: :popup)
              section.add_control(control_type: :link,
                                  text: 'Complete Sales Return',
                                  url: "/pack_material/sales_returns/mr_sales_returns/#{id}/complete_sales_return",
                                  prompt: true,
                                  id: 'mr_sales_returns_complete_button',
                                  visible: rules[:can_complete_sales_return],
                                  style: :button)
            end

            page.section do |section|
              section.form do |form|
                form.caption 'Edit Sales Return'
                form.action "/pack_material/sales_returns/mr_sales_returns/#{id}"
                form.method :update unless cannot_edit
                form.view_only! if cannot_edit
                form.no_submit! if cannot_edit
                form.row do |row|
                  row.column do |column|
                    column.add_field :sales_return_number
                    column.add_field :mr_sales_order_id
                    column.add_field :issue_transaction_id
                    column.add_field :sales_order_number
                    column.add_field :created_by
                  end

                  row.column do |column|
                    column.add_field :remarks
                    column.add_text sales_return_totals(rules)
                  end
                end
              end
            end

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Print Sales Return',
                                  url: "/pack_material/reports/print_sales_return/#{id}",
                                  loading_window: true,
                                  visible: rules[:completed],
                                  style: :button)
              section.add_control(control_type: :link,
                                  text: "#{Crossbeams::Layout::Icon.render(:envelope)} Email Sales Return",
                                  url: "/pack_material/reports/email_sales_return/#{id}",
                                  behaviour: :popup,
                                  visible: rules[:completed],
                                  style: :button)
            end

            page.section do |section|
              section.show_border!
              sales_return_items_grid = rules[:verified] ? 'mr_sales_return_items_show' : 'mr_sales_return_items'
              section.add_control(control_type: :link,
                                  text: 'New Item',
                                  url: "/pack_material/sales_returns/mr_sales_returns/#{id}/mr_sales_return_items/new",
                                  style: :button,
                                  behaviour: :popup,
                                  grid_id: 'sales_return_items',
                                  css_class: 'mb1')
              section.add_grid('sales_return_items',
                               "/list/#{sales_return_items_grid}/grid?key=standard&mr_sales_return_id=#{id}",
                               height: 16,
                               caption: 'Sales Return Items')
            end
          end

          layout
        end

        def self.sales_return_totals(rules)
          <<~HTML
            <div class="fr">
            <table><tbody>
            <tr><th class="tr pr2">Sub-total</th><td class="tr"><span id="sales_return_totals_subtotal">#{rules[:sales_return_sub_totals][:subtotal]}</span></td></tr>
            <tr><th class="tr pr2">Costs</th><td class="tr"><span id="sales_return_totals_costs">#{rules[:sales_return_sub_totals][:costs]}</span></td></tr>
            <tr><th class="tr pr2">VAT</th><td class="tr"><span id="sales_return_totals_vat">#{rules[:sales_return_sub_totals][:vat]}</span></td></tr>
            <tr><th class="tr pr2">Total</th><td class="tr b bb bt"><span id="sales_return_totals_total">#{rules[:sales_return_sub_totals][:total]}</span></td></tr>
            </tbody></table>
            </div>
          HTML
        end
      end
    end
  end
end
