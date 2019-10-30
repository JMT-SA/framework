# frozen_string_literal: true

namespace :app do
  namespace :masterfiles do
    desc 'Import locations'
    task :import_locations, [:fn] => [:load_app] do |_, args|
      res = MasterfilesApp::ImportLocations.call(args.fn)
      if res.success
        puts "SUCCESS: #{res.message}"
      else
        puts "FAILURE: #{res.message}"
      end
    end

    desc 'SQL Extract of Masterfiles'
    task extract: [:load_app] do
      # Todo - allow list of specific tables
      extractor = SecurityApp::DataToSql.new(nil)
      Crossbeams::Config::MF_BASE_TABLES.each do |table|
        puts "-- #{table.to_s.upcase} --"
        extractor.sql_for(table, nil)
        puts ''
      end

      Crossbeams::Config::MF_TABLES_IN_SEQ.each do |table|
        puts "-- #{table.to_s.upcase} --"
        extractor.sql_for(table, nil)
        puts ''
      end
    end

    desc 'SQL Extract of single Masterfile'
    task :extract_single, [:table] => [:load_app] do |_, args|
      table = args.table
      extractor = SecurityApp::DataToSql.new(nil)
      puts "-- #{table.to_s.upcase} --"
      extractor.sql_for(table.to_sym, nil)
      puts ''
    end
  end

  # Just trying something... TODO: get the rest of the params passed in
  namespace :jasper do
    desc 'Run a Jasper report'
    task :run_report, %i[rpt fname] => [:load_app] do |_, args|
      res = CreateJasperReport.call(report_name: args.rpt,
                                    user: 'rakeU',
                                    file: args.fname,
                                    params: { invoice_id: 1,
                                              invoice_type: 'CUSTOMER',
                                              keep_file: true })
      if res.success
        puts "REPORT CREATED: #{res.instance}"
      else
        puts "ERROR: #{res.message}"
      end
    end
  end
end

# class AppMfTasks
#   include Rake::DSL
#
#   def initialize
#     namespace :app do
#       namespace :masterfiles do
#         desc 'AAA'
#         task :import_locations do
#           puts 'In DSL'
#         end
#       end
#     end
#   end
# end
# # Instantiate the class to define the tasks:
# AppMfTasks.new
