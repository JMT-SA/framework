# frozen_string_literal: true

module DM
  module Admin
    class ChangeSql
      def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
        # ui_rule = UiRules::Compiler.new(:user, :edit, id: id, form_values: form_values)
        # rules   = ui_rule.compile
        # report = lookup_admin_report(id) # TODO: create a repo for this...
        repo    = DataminerApp::ReportRepo.new
        report  = repo.lookup_admin_report(id)
        obj     = OpenStruct.new
        obj.id  = id
        obj.sql = report.sql
        rules   = { fields: { id: { renderer: :hidden },
                              sql: { renderer: :textarea,
                                     cols: 60,
                                     rows: 25 } },
                    name: 'report' }

        layout = Crossbeams::Layout::Page.build(rules) do |page| # rubocop:disable Metrics/BlockLength
          # page.form_object ui_rule.form_object
          page.form_object obj
          page.form_values form_values
          page.form_errors form_errors
          page.form do |form|
            form.action "/dataminer/admin/#{id}/save_new_sql"
            # form.remote!
            form.method :update
            form.row do |row|
              row.column do |col|
                # col.relative_width = 2-3
                col.add_field :id
                col.add_field :sql
              end
              row.column do |col|
                # col.relative_width = 1-3
                col.fold_up do |fold|
                  fold.caption 'A few useful SQL snippets'
                  fold.add_text <<~SQL, syntax: :sql
                    -- Use row number as id
                    ROW_NUMBER() OVER() AS id

                    -- Collect several strings into one column
                    (SELECT string_agg(code, '; ')
                    FROM (SELECT code
                          FROM table_two
                          WHERE table_two.id = table_one.table_two_id) sub) AS all_codes

                    -- Status column
                    fn_current_status('tablename', tablename.id) AS status
                  SQL
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
