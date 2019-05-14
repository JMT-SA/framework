# frozen_string_literal: true

module LabelPrintingApp
  # Apply an instance's values to a label template's variable rules and print a quantity of labels.
  class PrintLabel < BaseService
    attr_reader :label_name, :instance, :quantity, :printer_id

    def initialize(label_name, instance, params)
      @label_name = label_name
      @instance = instance
      @quantity = params[:no_of_prints] || 1
      @printer_id = params[:printer]
      raise ArgumentError if label_name.nil?
    end

    def call
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
      lbl_required.each_with_index do |resolver, index|
        vars["F#{index + 1}".to_sym] = value_from(resolver)
      end
      vars
    end

    def value_from(resolver)
      case resolver
      when /\ABCD:/
        make_barcode(resolver.delete_prefix('BCD:'))
      when /\AFNC:/
        make_function(resolver.delete_prefix('FNC:'))
      when /\ACMP:/
        make_composite(resolver.delete_prefix('CMP:'))
      else
        instance[resolver.to_sym]
      end
    end

    def make_function(resolver)
      "Functions not yet implemented - #{resolver}"
    end

    def make_composite(resolver)
      # Example: 'CMP:x:${Location Long Code} - ${Location Short Code} / ${FNC:some_function,Location Long Code}'
      tokens = resolver.scan(/\$\{(.+?)\}/)
      output = resolver
      tokens.flatten.each { |token| output.gsub!("${#{token}}", value_from(token).to_s) }
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

      label_template.variable_rules['variables'].map do |var|
        var.values.first['resolver']
      end
    end
  end
end
