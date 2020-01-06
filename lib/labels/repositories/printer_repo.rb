# frozen_string_literal: true

module LabelApp
  class PrinterRepo < BaseRepo # rubocop:disable Metrics/ClassLength
    build_for_select :printers,
                     label: %i[printer_name printer_type],
                     value: :id,
                     order_by: :printer_name

    build_for_select :printer_applications,
                     label: :application,
                     value: :id,
                     order_by: :application
    build_inactive_select :printer_applications,
                          label: :application,
                          value: :id,
                          order_by: :application

    build_for_select :mes_modules,
                     label: :module_code,
                     value: :id,
                     order_by: :module_code
    build_inactive_select :mes_modules,
                          label: :module_code,
                          value: :id,
                          order_by: :module_code

    crud_calls_for :printers, name: :printer, wrapper: Printer

    crud_calls_for :printer_applications, name: :printer_application, wrapper: PrinterApplication

    crud_calls_for :mes_modules, name: :mes_module, wrapper: MesModule

    def refresh_and_add_printers(ip_or_address, printer_list) # rubocop:disable Metrics/AbcSize
      server_ip = UtilityFunctions.ip_from_uri(ip_or_address)
      printer_codes = printer_list.map { |a| a['Code'] }
      qry = <<~SQL
        UPDATE printers
        SET active = false
        WHERE server_ip = '#{server_ip}'
          AND printer_use = '#{AppConst::PRINTER_USE_INDUSTRIAL}'
          AND printer_code NOT IN ('#{printer_codes.join("', '")}');
      SQL
      DB.transaction do # rubocop:disable Metrics/BlockLength
        DB.execute(qry)
        printer_list.each do |printer|
          rec = {
            printer_code: printer['Code'],
            printer_name: printer['Alias'],
            printer_type: printer['Type'],
            pixels_per_mm: printer['PixelMM'].to_i,
            printer_language: printer['Language']
          }
          DB[:printers].insert_conflict(target: %i[server_ip printer_code],
                                        update: {
                                          printer_name: Sequel[:excluded][:printer_name],
                                          printer_type: Sequel[:excluded][:printer_type],
                                          pixels_per_mm: Sequel[:excluded][:pixels_per_mm],
                                          printer_language: Sequel[:excluded][:printer_language],
                                          server_ip: server_ip,
                                          active: true,
                                          printer_use: AppConst::PRINTER_USE_INDUSTRIAL
                                        }).insert(printer_code: rec[:printer_code],
                                                  printer_name: rec[:printer_name],
                                                  printer_type: rec[:printer_type],
                                                  pixels_per_mm: rec[:pixels_per_mm],
                                                  printer_language: rec[:printer_language],
                                                  server_ip: server_ip,
                                                  printer_use: AppConst::PRINTER_USE_INDUSTRIAL)
        end
      end
    end

    def refresh_and_add_server_printers(ip_or_address, printer_codes)
      server_ip = UtilityFunctions.ip_from_uri(ip_or_address)
      qry = <<~SQL
        UPDATE printers
        SET active = false
        WHERE server_ip = '#{server_ip}'
          AND printer_use = '#{AppConst::PRINTER_USE_OFFICE}'
          AND printer_code NOT IN ('#{printer_codes.join("', '")}');
      SQL
      DB.transaction do
        DB.execute(qry)
        printer_codes.each do |printer|
          rec = {
            printer_code: printer,
            printer_name: printer
          }
          DB[:printers].insert_conflict(target: %i[server_ip printer_code],
                                        update: {
                                          printer_name: Sequel[:excluded][:printer_name],
                                          server_ip: server_ip,
                                          active: true,
                                          printer_use: AppConst::PRINTER_USE_OFFICE
                                        }).insert(printer_code: rec[:printer_code],
                                                  printer_name: rec[:printer_name],
                                                  server_ip: server_ip,
                                                  printer_use: AppConst::PRINTER_USE_OFFICE)
        end
      end
    end

    def unset_default_printer(id, res)
      DB[:printer_applications].where(application: res.to_h[:application]).exclude(id: id).update(default_printer: false)
    end

    def distinct_px_mm
      DB[:printers].distinct.select_map(:pixels_per_mm).sort
    end

    def printers_for(px_per_mm)
      DB[:printers].where(pixels_per_mm: px_per_mm, active: true).map { |p| [p[:printer_name], p[:printer_code]] }
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

    def select_printers_for_application(application) # rubocop:disable Metrics/AbcSize
      DB[:printers].join(:printer_applications, printer_id: :id)
                   .where(application: application, Sequel[:printers][:active] => true, Sequel[:printer_applications][:active] => true)
                   .select(Sequel[:printers][:printer_name], Sequel[:printers][:id])
                   .order(:printer_name)
                   .map { |p| [p[:printer_name], p[:id]] }
    end

    def default_printer_for_application(application)
      DB[:printer_applications].where(application: application, default_printer: true, active: true).get(:printer_id)
    end

    def refresh_and_add_mes_modules(ip_or_address, module_list) # rubocop:disable Metrics/AbcSize
      server_ip = UtilityFunctions.ip_from_uri(ip_or_address)
      module_codes = module_list.map { |a| a['Code'] }
      qry = <<~SQL
        UPDATE mes_modules
        SET active = false
        WHERE server_ip = '#{server_ip}'
          AND module_code NOT IN ('#{module_codes.join("', '")}');
      SQL
      DB.transaction do
        DB.execute(qry)
        module_list.each do |mes_module|
          rec = {
            module_code: mes_module['Code'],
            module_type: mes_module['Function'],
            ip_address: mes_module['NetworkInterface'],
            port: mes_module['Port'].to_i,
            alias: mes_module['Alias']
          }
          DB[:mes_modules].insert_conflict(target: %i[server_ip module_code],
                                           update: {
                                             alias: Sequel[:excluded][:alias],
                                             module_type: Sequel[:excluded][:module_type],
                                             ip_address: Sequel[:excluded][:ip_address],
                                             port: Sequel[:excluded][:port],
                                             server_ip: server_ip,
                                             active: true
                                           }).insert(module_code: rec[:module_code],
                                                     alias: rec[:alias],
                                                     module_type: rec[:module_type],
                                                     ip_address: rec[:ip_address],
                                                     port: rec[:port],
                                                     server_ip: server_ip)
        end
      end
    end

    def print_to_robot?(ip_address)
      DB[:mes_modules].where(ip_address: ip_address).count.positive?
    end
  end
end
