# frozen_string_literal: true

module LabelPrintingApp
  # Apply an instance's values to a label template's variable rules and print a quantity of labels.
  class PrintLabel < BaseService
    include LabelContent

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

    def printer_code(printer)
      repo = LabelApp::PrinterRepo.new
      repo.find_hash(:printers, printer)[:printer_code]
    end

    def messerver_print(vars, printer_code)
      mes_repo = MesserverApp::MesserverRepo.new
      mes_repo.print_published_label(label_name, vars, quantity, printer_code)
    end
  end
end
