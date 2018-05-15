# frozen_string_literal: true

module Dataminer
  module Report
    module PreparedReport
      class New
        def self.call(id, json_var, form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:prepared_report, :new, id: id, form_values: form_values, json_var: json_var)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/dataminer/reports/prepared_reports/'
              form.remote! if remote
              form.add_field :id
              form.add_field :json_var
              form.add_field :database
              form.add_field :report_template
              form.add_field :report_description
              # change param
              # webq only
              # users
              # replace existing
            end
          end

          layout
        end
      end
    end
  end
end
