# frozen_string_literal: true

module UiRules
  class LabelTemplateRule < Base
    def generate_rules
      @repo = MasterfilesApp::LabelTemplateRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show
      set_variable_upload_fields if @mode == :variables

      form_name 'label_template'
    end

    def set_variable_upload_fields
      fields[:label_template_name] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:variables] = { renderer: :file, accept: '.xml', caption: 'Upload variable xml file', required: true }
    end

    def set_show_fields
      fields[:label_template_name] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:application] = { renderer: :label }
      fields[:variables] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        label_template_name: { required: true },
        description: { required: true },
        application: { renderer: :select, options: AppConst::PRINTER_APPLICATIONS, required: true },
        variables: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_label_template(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(label_template_name: nil,
                                    description: nil,
                                    application: nil,
                                    variables: nil)
    end
  end
end
