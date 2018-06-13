# frozen_string_literal: true

module DM
  module Report
    module PreparedReport
      class Edit
        def self.call(id, form_values: nil, form_errors: nil)
          ui_rule = UiRules::Compiler.new(:prepared_report, :edit, id: id, form_values: form_values, form_errors: form_errors)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/dataminer/prepared_reports/#{id}"
              form.method :update
              form.remote!
              form.add_field :id
              form.add_field :report_description
              form.add_field :linked_users
            end
          end

          layout
        end
      end
    end
  end
end
