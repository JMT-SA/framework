# frozen_string_literal: true

module LabelApp
  class PrinterRepo < BaseRepo
    build_for_select :printers,
                     label: %i[printer_name printer_type],
                     value: :id,
                     no_active_check: true,
                     order_by: :printer_name

    build_for_select :printer_applications,
                     label: :application,
                     value: :id,
                     order_by: :application
    build_inactive_select :printer_applications,
                          label: :application,
                          value: :id,
                          order_by: :application

    crud_calls_for :printers, name: :printer, wrapper: Printer

    crud_calls_for :printer_applications, name: :printer_application, wrapper: PrinterApplication

    def delete_and_add_printers(printer_list)
      DB.transaction do
        DB[:printers].delete
        printer_list.each do |printer|
          rec = {
            printer_code: printer['Code'],
            printer_name: printer['Alias'],
            printer_type: printer['Type'],
            pixels_per_mm: printer['PixelMM'].to_i,
            printer_language: printer['Language']
          }
          create_printer(rec)
        end
      end
    end

    def distinct_px_mm
      DB[:printers].distinct.select_map(:pixels_per_mm).sort
    end

    def printers_for(px_per_mm)
      DB[:printers].where(pixels_per_mm: px_per_mm).map { |p| [p[:printer_name], p[:printer_code]] }
    end

    def find_printer_application(id)
      find_with_association(:printer_applications, id,
                            wrapper: PrinterApplication,
                            parent_tables: [
                              { parent_table: :printers,
                                columns: %i[printer_code printer_name],
                                flatten_columns: { printer_code: :printer_code,  printer_name: :printer_name } }
                            ])
    end

    def select_printers_for_application(application)
      DB[:printers].join(:printer_applications, printer_id: :id)
                   .where(application: application)
                   .select(Sequel[:printers][:printer_name], Sequel[:printers][:id])
                   .order(:printer_name)
                   .map { |p| [p[:printer_name], p[:id]] }
    end
  end
end
