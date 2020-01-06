# frozen_string_literal: true

module UiRules
  class MesModuleRule < Base
    def generate_rules
      @repo = LabelApp::PrinterRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode

      form_name 'mes_module'
    end

    def set_show_fields
      fields[:module_code] = { renderer: :label }
      fields[:module_type] = { renderer: :label }
      fields[:server_ip] = { renderer: :label }
      fields[:ip_address] = { renderer: :label }
      fields[:port] = { renderer: :label }
      fields[:alias] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        module_code: { required: true },
        module_type: { required: true },
        server_ip: { required: true },
        ip_address: { required: true },
        port: { required: true },
        alias: { required: true }
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_mes_module(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(module_code: nil,
                                    module_type: nil,
                                    server_ip: nil,
                                    ip_address: nil,
                                    port: nil,
                                    alias: nil)
    end
  end
end
