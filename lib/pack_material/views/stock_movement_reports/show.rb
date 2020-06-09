# frozen_string_literal: true

module PackMaterial
  module Transactions
    module StockMovementReport
      class Show
        def self.call(start_date, end_date, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:stock_movement_report, :show, form_values: form_values, start_date: start_date, end_date: end_date)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.section do |section|
              section.form do |form|
                form.caption 'Stock Movement Report'
                form.view_only!
                form.no_submit!
                form.add_field :start_date
                form.add_field :end_date
              end
            end

            page.section do |section|
              section.add_grid('stock_movement_report',
                               "/pack_material/transactions/movement_report/report/with_params?start_date=#{start_date}&end_date=#{end_date}",
                               caption: 'Stock Movement Report')
            end

            page.section do |section|
              section.add_grid('stock_movement_records',
                               "/pack_material/transactions/movement_report/records/with_params?start_date=#{start_date}&end_date=#{end_date}",
                               caption: 'Stock Movement Records')
            end
          end

          layout
        end
      end
    end
  end
end
