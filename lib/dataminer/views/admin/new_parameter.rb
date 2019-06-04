# frozen_string_literal: true

module DM
  module Admin
    class NewParameter
      def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
        ui_rule = UiRules::Compiler.new(:parameter, :new, id: id, form_values: form_values)
        rules   = ui_rule.compile
        # # report = lookup_admin_report(id) # TODO: create a repo for this...
        # repo    = DataminerApp::ReportRepo.new
        # report  = repo.lookup_admin_report(id)
        # cols    = report.ordered_columns.map(&:namespaced_name).compact
        # tables  = report.tables
        # obj     = OpenStruct.new
        # rules   = {
        #   fields: {
        #     column: { renderer: :select, options: cols }, # cols...
        #     table: { renderer: :select, options: tables }, # ...
        #     field: {},
        #     caption: {},
        #     data_type: { renderer: :select, options: [['String', 'string'], ['Integer', 'integer'], ['Number', 'number'], ['Date', 'date'], ['Date-Time', 'datetime'], ['Boolean', 'boolean']] },
        #     control_type: { renderer: :select, options: [['Text box', 'text'], ['Dropdown list', 'list'], ['Date range', 'daterange']] },
        #     list_def: {},
        #     default_value: {}
        #   },
        #   name: 'report'
        # }

        layout = Crossbeams::Layout::Page.build(rules) do |page| # rubocop:disable Metrics/BlockLength
          page.form_object ui_rule.form_object
          # page.form_object obj
          page.form_values form_values
          page.form_errors form_errors
          page.section do |section| # rubocop:disable Metrics/BlockLength
            section.add_text('Choose a column or choose a table with field. Use the second option when requiring a parameter that is not returned by the query.')
            section.form do |form|
              form.action "/dataminer/admin/#{id}/parameter/create"
              # form.remote!
              form.row do |row|
                row.column do |col|
                  col.add_field :column
                end
              end
              form.row do |row|
                row.column do |col|
                  col.add_field :table
                end
                row.column do |col|
                  col.add_field :field
                end
              end
              form.row do |row|
                row.column do |col|
                  col.add_field :caption
                  col.add_field :data_type
                  col.add_field :control_type
                  col.add_field :list_def
                  col.add_field :default_value
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
