# frozen_string_literal: true

module UiRules
  class ReportRule < Base
    def generate_rules
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      fields[:database] = { renderer: :hidden } if @options[:for_grids]

      form_name 'report'
    end

    def common_fields
      {
        database: { renderer: :select, options: DM_CONNECTIONS.databases(without_grids: true, without_system: true) },
        filename: { placeholder: 'filename.yml', required: true },
        caption: {}, # placeholder: 'Caption', required: true },
        sql: { renderer: :textarea, rows: 20 }
      }
    end

    def make_form_object
      @form_object = OpenStruct.new(database: nil, filename: nil, caption: nil, sql: nil)
      @form_object.database = DataminerApp::ReportRepo::GRID_DEFS if @options[:for_grids]
    end
  end
end
