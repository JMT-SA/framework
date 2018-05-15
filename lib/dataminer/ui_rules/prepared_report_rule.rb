# frozen_string_literal: true

module UiRules
  class PreparedReportRule < Base
    def generate_rules
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      # fields[:database] = { renderer: :hidden } if @options[:for_grids]

      form_name 'prepared_report'
    end

    def common_fields
      {
        database: { readonly: true },
        report_template: { readonly: true },
        report_description: { required: true },
        id: { renderer: :hidden },
        json_var: { renderer: :hidden }
      }
    end

    def make_form_object
      @form_object = OpenStruct.new(id: @options[:id],
                                    database: @options[:id].split('_').first,
                                    report_template: @options[:id].split('_').last,
                                    json_var: @options[:json_var],
                                    report_description: nil) # could start with current rpt desc
    end
  end
end
