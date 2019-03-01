# frozen_string_literal: true

module UiRules
  class PrinterApplicationRule < Base
    def generate_rules
      @repo = LabelApp::PrinterRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'printer_application'
    end

    def set_show_fields
      # printer_id_label = LabelApp::PrinterRepo.new.find_printer(@form_object.printer_id)&.printer_code
      printer_id_label = @repo.find(:printers, LabelApp::Printer, @form_object.printer_id)&.printer_code
      fields[:printer_id] = { renderer: :label, with_value: printer_id_label, caption: 'Printer' }
      fields[:application] = { renderer: :label }
      fields[:default_printer] = { renderer: :label, as_boolean: true, caption: 'Default printer for application' }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        printer_id: { renderer: :select, options: LabelApp::PrinterRepo.new.for_select_printers, caption: 'Printer', required: true },
        application: { renderer: :select, options: AppConst::PRINTER_APPLICATIONS, required: true },
        default_printer: { renderer: :checkbox, caption: 'Default printer for application' }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_printer_application(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(printer_id: nil,
                                    application: nil,
                                    default_printer: false)
    end
  end
end
