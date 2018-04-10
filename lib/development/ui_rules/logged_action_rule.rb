# frozen_string_literal: true

module UiRules
  class LoggedActionRule < Base
    def generate_rules
      @repo = DevelopmentApp::LoggingRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'logged_action'
    end

    def set_show_fields
      fields[:schema_name] = { renderer: :label }
      fields[:table_name] = { renderer: :label }
      fields[:row_data_id] = { renderer: :label, caption: 'Id' }
    end

    def common_fields
      {
        schema_name: { required: true },
        table_name: { required: true },
        row_data_id: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_logged_action(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(schema_name: nil,
                                    table_name: nil,
                                    row_data_id: nil)
    end
  end
end
