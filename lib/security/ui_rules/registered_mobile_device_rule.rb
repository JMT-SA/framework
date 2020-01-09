# frozen_string_literal: true

module UiRules
  class RegisteredMobileDeviceRule < Base
    def generate_rules
      @repo = SecurityApp::RegisteredMobileDeviceRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'registered_mobile_device'
    end

    def set_show_fields
      start_page_program_function_id_label = @repo.find(:program_functions, SecurityApp::ProgramFunction, @form_object.start_page_program_function_id)&.program_function_name
      fields[:ip_address] = { renderer: :label }
      fields[:start_page_program_function_id] = { renderer: :label, with_value: start_page_program_function_id_label, caption: 'Start Page' }
      fields[:active] = { renderer: :label, as_boolean: true }
      fields[:scan_with_camera] = { renderer: :label, as_boolean: true }
      fields[:hybrid_device] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      hybrid_hint = <<~HTML
        <h2>Hybrid devices use standard pages as well as scanning pages</h2>
        <p>Set this to true for a device like a tablet/desktop that will use "normal" pages as well as scan pages.</p>
        <p>This should never be set to true for a mobile device that is used as a scanning device only.</p>
      HTML
      @menu_repo = SecurityApp::MenuRepo.new
      {
        ip_address: { pattern: :ipv4_address, required: true },
        start_page_program_function_id: { renderer: :select, options: SecurityApp::MenuRepo.new.program_functions_for_rmd_select, caption: 'Start Page', prompt: true },
        active: { renderer: :checkbox },
        scan_with_camera: { renderer: :checkbox },
        hybrid_device: { renderer: :checkbox, hint: hybrid_hint }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_registered_mobile_device(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(ip_address: nil,
                                    start_page_program_function_id: nil)
    end
  end
end
