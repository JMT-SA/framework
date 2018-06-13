# frozen_string_literal: true

module DM
  module Report
    module PreparedReport
      class ChangeColumns
        def self.call(id, instance, report, remote = true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:prepared_report, :change_columns, instance: instance, report: report)
          rules   = ui_rule.compile
          cols = report.ordered_columns.reject(&:hide).map { |column| ["#{column.name} (#{column.caption})", column.name] }
          hidden = report.ordered_columns.select(&:hide).map { |column| ["#{column.name} (#{column.caption})", column.name] }

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.remote! if remote
              form.action "/dataminer/prepared_reports/#{id}/save_columns"
              form.method :update

              form.row do |row|
                row.column do |col|
                  col.add_field :report_description
                  col.add_text 'Drag and drop columns within a list to re-order; drag from one list to another to hide/show a column.', wrapper: %i[p em]
                end
              end

              form.row do |row|
                row.column do |col|
                  col.add_sortable_list('co', cols, drag_between_lists_name: 'columns', caption: 'Sequence of columns')
                end

                row.column do |col|
                  col.add_sortable_list('hc', hidden, drag_between_lists_name: 'columns', caption: 'Columns to hide')
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
