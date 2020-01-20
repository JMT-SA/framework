# frozen_string_literal: true

module PackMaterial
  module Dispatch
    module MrSalesOrder
      class Edit
        def self.call(id, current_user, form_values: nil, form_errors: nil, interactor: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_sales_order, :edit, id: id, form_values: form_values, current_user: current_user, interactor: interactor)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page| # rubocop:disable Metrics/BlockLength
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Back to Sales Orders',
                                  url: "/list/mr_sales_orders/with_params?key=#{rules[:shipped] ? 'shipped' : 'unshipped'}",
                                  style: :back_button)
              section.add_control(control_type: :link,
                                  text: 'Ship Goods',
                                  url: "/pack_material/sales/mr_sales_orders/#{id}/ship_goods",
                                  prompt: true,
                                  id: 'mr_sales_orders_ship_button',
                                  visible: rules[:can_ship],
                                  style: :button)
            end

            page.section do |section| # rubocop:disable Metrics/BlockLength
              section.form do |form|
                form.caption 'Edit Sales Order'
                form.action "/pack_material/sales/mr_sales_orders/#{id}"
                form.remote!
                form.method :update
                form.row do |row|
                  row.column do |column|
                    column.add_field :sales_order_number
                    column.add_field :customer_party_role_id
                    column.add_field :dispatch_location_id
                    column.add_field :issue_transaction_id
                    column.add_field :vat_type_id
                    column.add_field :account_code_id
                    column.add_field :fin_object_code
                  end
                  row.column do |column|
                    column.add_field :erp_customer_number
                    column.add_field :created_by
                    column.add_field :valid_until
                    column.add_field :shipped_at
                    column.add_field :integration_error
                    column.add_field :integration_completed
                    column.add_field :shipped
                  end
                end
              end
            end

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Print Sales Order',
                                  url: "/pack_material/reports/print_sales_order/#{id}",
                                  loading_window: true,
                                  visible: rules[:shipped],
                                  style: :button)
            end

            page.section do |section|
              section.show_border!
              if rules[:shipped]
                section.add_grid('so_items',
                                 "/list/mr_sales_order_items_show/grid?key=standard&mr_sales_order_id=#{id}",
                                 height: 16,
                                 caption: 'Sales Order Items')
              else
                section.add_control(control_type: :link,
                                    text: 'New Item',
                                    url: "/pack_material/sales/mr_sales_orders/#{id}/mr_sales_order_items/new",
                                    style: :button,
                                    behaviour: :popup,
                                    grid_id: 'so_items',
                                    css_class: 'mb1')
                section.add_grid('so_items',
                                 "/list/mr_sales_order_items/grid?key=standard&mr_sales_order_id=#{id}",
                                 height: 16,
                                 caption: 'Sales Order Items')
              end
            end
          end

          layout
        end
      end
    end
  end
end
