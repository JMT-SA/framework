# frozen_string_literal: true

module PackMaterial
  module Transactions
    module MrBulkStockAdjustment
      class Edit # rubocop:disable Metrics/ClassLength
        def self.call(id, current_user, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          ui_rule = UiRules::Compiler.new(:mr_bulk_stock_adjustment, :edit, id: id, form_values: form_values, current_user: current_user)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page| # rubocop:disable Metrics/BlockLength
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors

            page.section do |section| # rubocop:disable Metrics/BlockLength
              section.add_control(control_type: :link,
                                  text: rules[:back_caption],
                                  url: rules[:back_link],
                                  style: :back_button)
              section.add_control(control_type: :link,
                                  text: 'Complete',
                                  url: "/pack_material/transactions/mr_bulk_stock_adjustments/#{id}/complete",
                                  prompt: true,
                                  style: :button,
                                  visible: rules[:can_complete],
                                  id: 'mr_bulk_stock_adjustments_complete_button')

              price_url = rules[:signed_off] ? '/list/mr_bulk_stock_adjustment_prices_show' : '/list/mr_bulk_stock_adjustment_prices'
              section.add_control(control_type: :link,
                                  text: 'Manage Prices',
                                  url: price_url + "/with_params?key=standard&mr_bulk_stock_adjustment_id=#{id}",
                                  style: :button,
                                  visible: rules[:can_manage_prices],
                                  behaviour: :popup)
              if rules[:can_approve]
                section.add_control(control_type: :link,
                                    text: 'Reopen',
                                    url: "/pack_material/transactions/mr_bulk_stock_adjustments/#{id}/reopen",
                                    prompt: true,
                                    style: :button)
                section.add_control(control_type: :link,
                                    text: 'Approve',
                                    url: "/pack_material/transactions/mr_bulk_stock_adjustments/#{id}/approve",
                                    prompt: true,
                                    style: :button)
              end
              if rules[:can_sign_off]
                section.add_control(control_type: :link,
                                    text: 'Reopen',
                                    url: "/pack_material/transactions/mr_bulk_stock_adjustments/#{id}/decline",
                                    prompt: true,
                                    style: :button)
                section.add_control(control_type: :link,
                                    text: 'Sign Off',
                                    url: "/pack_material/transactions/mr_bulk_stock_adjustments/#{id}/sign_off",
                                    prompt: true,
                                    style: :button)
              end
              if rules[:can_integrate]
                section.add_control(control_type: :link,
                                    text: 'Integrate',
                                    url: "/pack_material/transactions/mr_bulk_stock_adjustments/#{id}/integrate",
                                    prompt: true,
                                    style: :button)
              end
            end
            page.section do |section|
              section.show_border!
              section.add_caption 'Bulk Stock Adjustment'
              section.form do |form|
                form.view_only! if rules[:show_only]
                form.method :update unless rules[:show_only]
                form.no_submit!
                form.row do |row|
                  row.column do |col|
                    col.add_field :stock_adjustment_number
                    col.add_field :ref_no
                  end
                  row.column do |col|
                    col.add_field :completed
                    col.add_field :approved
                    col.add_field :signed_off
                  end
                end
              end
            end

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Stock Adjustment Sheet',
                                  url: "/pack_material/reports/stock_adjustment_sheet/#{id}",
                                  loading_window: true,
                                  visible: !rules[:signed_off],
                                  style: :button)
              section.add_control(control_type: :link,
                                  text: 'Preliminary Report',
                                  url: "/pack_material/reports/preliminary_report/#{id}",
                                  loading_window: true,
                                  visible: !rules[:signed_off],
                                  style: :button)
              section.add_control(control_type: :link,
                                  text: 'Signed Off Report',
                                  url: "/pack_material/reports/signed_off_report/#{id}",
                                  loading_window: true,
                                  visible: rules[:signed_off],
                                  style: :button)
            end

            page.section do |section|
              section.show_border!

              if rules[:show_only]
                section.add_grid('blk_stck_adj_items',
                                 "/list/mr_bulk_stock_adjustment_items_show/grid?key=standard&mr_bulk_stock_adjustment_id=#{id}",
                                 caption: 'Bulk Stock Adjustment Items')
              else
                section.add_control(control_type: :link,
                                    text: 'New Item',
                                    url: "/pack_material/transactions/mr_bulk_stock_adjustments/#{id}/mr_bulk_stock_adjustment_items/new",
                                    style: :button,
                                    behaviour: :popup,
                                    grid_id: 'blk_stck_adj_items',
                                    css_class: 'mb1')
                section.add_grid('blk_stck_adj_items',
                                 "/list/mr_bulk_stock_adjustment_items/grid?key=standard&mr_bulk_stock_adjustment_id=#{id}",
                                 caption: 'Bulk Stock Adjustment Items')
              end
            end
          end

          layout
        end
      end
    end
  end
end
