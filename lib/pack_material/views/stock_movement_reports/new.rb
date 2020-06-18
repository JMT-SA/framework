# frozen_string_literal: true

module PackMaterial
  module Transactions
    module StockMovementReport
      class New
        def self.call(form_values: nil, form_errors: nil, remote: false) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:stock_movement_report, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New Stock Movement Report'
              form.action '/pack_material/transactions/movement_report'
              form.remote! if remote
              form.row do |row|
                row.column do |col|
                  col.add_field :start_month
                end
                row.column do |col|
                  col.add_field :start_year
                end
              end
              form.row do |row|
                row.column do |col|
                  col.add_field :end_date
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
