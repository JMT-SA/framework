# frozen_string_literal: true

module DM
  module Admin
    class ReorderColumns
      def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
        # ui_rule = UiRules::Compiler.new(:user, :edit, id: id, form_values: form_values)
        # rules   = ui_rule.compile
        repo    = DataminerApp::ReportRepo.new
        report  = repo.lookup_admin_report(id)
        cols    = report.ordered_columns.map { |column| ["#{column.name} (#{column.caption})", column.name] }
        obj     = OpenStruct.new
        obj.id  = id
        rules   = { fields: { id: { renderer: :hidden } }, name: 'report' }

        layout = Crossbeams::Layout::Page.build(rules) do |page|
          # page.form_object ui_rule.form_object
          page.form_object obj
          page.form_values form_values
          page.form_errors form_errors
          page.form do |form|
            form.action "/dataminer/admin/#{id}/save_reordered_columns"
            # form.remote!
            form.method :update
            form.add_field :id
            form.add_text 'Drag and drop to re-order. Press submit to save the new order.'
            form.add_sortable_list('dm', cols)
          end
        end

        layout
      end
    end
  end
end
