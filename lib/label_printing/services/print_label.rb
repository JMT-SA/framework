# frozen_string_literal: true

module LabelPrintingApp
  # Apply an instance's values to a label config and print a quantity of labels.
  class PrintLabel < BaseService
    attr_reader :label_name, :instance, :quantity, :printer_id, :config

    def initialize(label_name, instance, params)
      @label_name = label_name
      @instance = instance
      @quantity = params[:quantity] || 1
      @printer_id = params[:printer]
      raise ArgumentError if label_name.nil?
    end

    def call
      config_repo = LabelApp::SharedConfigRepo.new
      @config = config_repo.packmat_labels_config

      lbl_required = fields_for_label
      vars = values_from(lbl_required)
      messerver_print(vars,  printer_code(printer_id))
    rescue Crossbeams::FrameworkError => e
      failed_response(e.message)
    end

    private

    # Take a field and format it for barcode printing.
    #
    # @param instance [Hash, DryType, OpenStruct] - the entity or hash that contains required values.
    # @param field [string] - the field to be formatted.
    # @return [string] - the formatted barcode string ready for printing.
    def make_barcode(field)
      fmt_str = AppConst::BARCODE_PRINT_RULES[field.to_sym][:format]
      raise Crossbeams::FrameworkError, "There is no BARCODE PRINT RULE for #{field}" if fmt_str.nil?

      fields = AppConst::BARCODE_PRINT_RULES[field.to_sym][:fields]
      vals = fields.map { |f| instance[f] }
      assert_no_nil_fields!(vals, fields)

      format(fmt_str, *vals)
    end

    def assert_no_nil_fields!(vals, fields)
      return unless vals.any?(&:nil?)
      in_err = vals.zip(fields).select { |v, _| v.nil? }.map(&:last)

      raise Crossbeams::FrameworkError, "Make barcode: instance does not have a value for: #{in_err.join(', ')}"
    end

    def values_from(lbl_required)
      vars = {}
      lbl_required.each_with_index do |var, index|
        vars["F#{index + 1}".to_sym] = value_from(var)
      end
      vars
    end

    def value_from(varname)
      case varname
      when /\ABCD:/
        make_barcode(varname.delete_prefix('BCD:'))
      when /\AFNC:/
        make_function(varname.delete_prefix('FNC:'))
      when /\ACMP:/
        make_composite(varname.delete_prefix('CMP:'))
      else
        instance[varname.to_sym]
      end
    end

    def make_function(varname)
      "Functions not yet implemented - #{varname}"
    end

    def make_composite(varname)
      # Example: 'CMP:x:${Location Long Code} - ${Location Short Code} / ${FNC:some_function,Location Long Code}'
      tokens = varname.scan(/\$\{(.+?)\}/)
      output = varname
      tokens.flatten.each do |token|
        var_rule = resolver_for(token)
        raise Crossbeams::FrameworkError, 'A composite cannot include a composite in its makeup.' if var_rule.start_with?('CMP:')
        output.gsub!("${#{token}}", value_from(var_rule))
      end
      output
    end

    def printer_code(printer)
      repo = LabelApp::PrinterRepo.new
      repo.find_hash(:printers, printer)[:printer_code]
    end

    def messerver_print(vars, printer_code)
      mes_repo = MesserverApp::MesserverRepo.new
      mes_repo.print_label(label_name, vars, quantity, printer_code)
    end

    def fields_for_label
      repo = MasterfilesApp::LabelTemplateRepo.new
      label_template = repo.find_label_template_by_name(label_name)
      raise Crossbeams::FrameworkError, "There is no label template named \"#{label_name}\"." if label_template.nil?

      label_template.variables.map do |varname|
        resolver_for(varname)
      end
    end

    def resolver_for(varname)
      if varname.start_with?('CMP:')
        varname
      elsif varname.start_with?('FNC:')
        varname
      else
        config[varname][:resolver]
      end
    end
  end
end
