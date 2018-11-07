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
      # start_page_program_function_id_label = SecurityApp::ProgramFunctionRepo.new.find_program_function(@form_object.start_page_program_function_id)&.program_function_name
      start_page_program_function_id_label = @repo.find(:program_functions, SecurityApp::ProgramFunction, @form_object.start_page_program_function_id)&.program_function_name
      fields[:ip_address] = { renderer: :label }
      fields[:start_page_program_function_id] = { renderer: :label, with_value: start_page_program_function_id_label, caption: 'Start Page Program Function' }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        ip_address: { pattern: :ipv4_address, required: true },
        # start_page_program_function_id: { renderer: :select, options: SecurityApp::MenuRepo.new.program_functions_for_select, disabled_options: SecurityApp::MenuRepo.new.for_inactive_select_program_functions, caption: 'start_page_program_function' }
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
