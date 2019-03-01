# frozen_string_literal: true

module PackMaterial
  module Transactions
    module MrBulkStockAdjustment
      class Edit
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_bulk_stock_adjustment, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Back to Bulk Stock Adjustments',
                                  url: '/list/mr_bulk_stock_adjustments',
                                  style: :back_button)
              if rules[:can_complete] && !rules[:show_only]
                section.add_control(control_type: :link,
                                    text: 'Complete',
                                    url: "/pack_material/transactions/mr_bulk_stock_adjustments/#{id}/complete",
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
                  end
                  row.column do |col|
                    col.add_field :is_stock_take
                  end
                end
              end
            end

            page.section do |section|
              section.show_border!
              section.row do |row|
                row.column do |col|
                  if rules[:show_only]
                    col.add_grid('blk_stck_adj_items',
                                 "/list/mr_blk_stck_adj_items_show/grid?key=standard&mr_bulk_stock_adjustment_id=#{id}",
                                 height: 8,
                                 caption: 'Bulk Stock Adjustment Items')
                  else
                    col.add_control(control_type: :link,
                                    text: 'New Item',
                                    url: "/pack_material/transactions/mr_bulk_stock_adjustments/#{id}/mr_bulk_stock_adjustment_items/new",
                                    style: :button,
                                    behaviour: :popup,
                                    grid_id: 'blk_stck_adj_items',
                                    css_class: 'mb1')
                    col.add_grid('blk_stck_adj_items',
                                 "/list/mr_bulk_stock_adjustment_items/grid?key=standard&mr_bulk_stock_adjustment_id=#{id}",
                                 height: 8,
                                 caption: 'Bulk Stock Adjustment Items')
                  end
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
