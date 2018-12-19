# frozen_string_literal: true

module LabelPrintingApp
  class LabelPrintingInteractor < BaseInteractor
    def print_label(label_name, instance, params)
      lbl_required = fields_for_label(label_name)
      vars = values_from(instance, lbl_required)
      messerver_print(label_name, vars, params[:quantity] || 1, printer_code(params[:printer]))
    end

    # Take a field and format it for barcode printing.
    #
    # @param instance [Hash, DryType, OpenStruct] - the entity or hash that contains required values.
    # @param field [string] - the field to be formatted.
    # @return [string] - the formatted barcode string ready for printing.
    def make_barcode(instance, field)
      fmt_str = AppConst::BARCODE_PRINT_RULES[field.to_sym][:format]
      raise ArgumentError, "There is no BARCODE PRINT RULE for #{field}" if fmt_str.nil?

      vals = AppConst::BARCODE_PRINT_RULES[field.to_sym][:fields].map { |f| instance[f] }
      format(fmt_str, *vals)
    end

    private

    def values_from(instance, lbl_required)
      vars = {}
      lbl_required.each_with_index do |var, index|
        vars["F#{index + 1}".to_sym] = value_from(var, instance)
      end
      vars
    end

    def value_from(varname, instance)
      case varname
      when /\ABCD:/
        make_barcode(instance, varname.delete_prefix('BCD:'))
      when /\AFNC:/
        'Functions not yet implemented'
      else
        instance[varname.to_sym]
      end
    end

    def printer_code(printer)
      repo = LabelApp::PrinterRepo.new
      repo.find_hash(:printers, printer)[:printer_code]
    end

    def messerver_print(label_name, vars, quantity, printer_code)
      mes_repo = MesserverApp::MesserverRepo.new
      mes_repo.print_label(label_name, vars, quantity, printer_code)
    end

    def fields_for_label(label)
      repo = MasterfilesApp::LabelTemplateRepo.new
      label_template = repo.find_label_template_by_name(label)
      raise ArgumentError, "There is no label template named \"#{label}\"." if label_template.nil?

      config_repo = LabelApp::SharedConfigRepo.new
      config = config_repo.packmat_labels_config
      label_template.variables.map do |v|
        config[v][:resolver]
      end
    end
  end
end
