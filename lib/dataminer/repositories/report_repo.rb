# frozen_string_literal: true

module DataminerApp
  class ReportRepo
    include Crossbeams::Responses

    attr_reader :for_grid_queries

    GRID_DEFS = 'grid-definitions'

    def initialize(for_grid_queries = false)
      @for_grid_queries = for_grid_queries
    end

    # Check if a database connection from DM_CONNECTIONS for a specific key was made.
    #
    # @param key [String] the database key.
    # @return [Crossbeams::Response] the database connection status.
    def db_connected?(key)
      config = DM_CONNECTIONS.config(key)
      return success_response('ok') if config.connected

      failed_response(config.connection_error, key)
    end

    # Get the database connection from DM_CONNECTIONS for a specific key.
    #
    # @param key [String] the database key.
    # @return [Sequel::Database] the database connection.
    def db_connection_for(key)
      DM_CONNECTIONS[key]
    end

    # Get the report location path for admin purposes.
    #
    # @param dbanem [String] the database key.
    # @return [String] the report dir for the db key.
    def admin_report_path(dbname)
      if dbname == GRID_DEFS
        ENV['GRID_QUERIES_LOCATION']
      else
        DM_CONNECTIONS.report_path(dbname)
      end
    end

    class ReportLocation
      attr_reader :db, :id, :path, :combined

      def initialize(db_id, loc_for_admin = false, for_grid_queries = false)
        @combined = db_id
        @db = db_id.match(/\A(.+?)_/)[1]
        @id = db_id.delete_prefix("#{db}_")
        @path = DM_CONNECTIONS.report_path(@db)
        @path = ENV['GRID_QUERIES_LOCATION'] if loc_for_admin && for_grid_queries
      end
    end

    def split_db_and_id(db_id, loc_for_admin = false)
      rep_loc = ReportLocation.new(db_id, loc_for_admin, for_grid_queries)
      [rep_loc.db, rep_loc.id]
    end

    # Get a Report from an id.
    #
    # @param id [String] the report id.
    # @return [Crossbeams::Dataminer::Report] the report.
    def lookup_report(id, loc_for_admin = false)
      rep_loc = ReportLocation.new(id, loc_for_admin, for_grid_queries)
      get_report_by_id(rep_loc)
    end

    # Get a Report's crosstab configuration from an id.
    #
    # @param id [String] the report id.
    # @return [Hash] the crosstab configuration from the report's YAML definition.
    def lookup_crosstab(id, loc_for_admin = false)
      rep_loc = ReportLocation.new(id, loc_for_admin, for_grid_queries)
      get_report_by_id(rep_loc, crosstab_hash: true)
    end

    def lookup_file_name(id, loc_for_admin = false)
      rep_loc = ReportLocation.new(id, loc_for_admin, for_grid_queries)
      get_report_by_id(rep_loc, filename: true)
    end

    def load_report_dictionary(rep_loc)
      get_reports_for(rep_loc.db, rep_loc.path)
    end

    def get_report_by_id(rep_loc, opts = {})
      # config_file       = File.join(rep_loc.path, '.dm_report_list.yml')
      # report_dictionary = YAML.load_file(config_file)
      report_dictionary = load_report_dictionary(rep_loc)
      this_report       = report_dictionary[rep_loc.combined]
      return this_report[:file] if opts[:filename]

      if opts[:crosstab_hash]
        yml = YAML.load_file(this_report[:file])
        return yml[:crosstab]
      end
      persistor = Crossbeams::Dataminer::YamlPersistor.new(this_report[:file])
      Crossbeams::Dataminer::Report.load(persistor)
    end

    # Get an ADMIN Report from an id.
    #
    # @param id [String] the report id.
    # @return [Crossbeams::Dataminer::Report] the report.
    def lookup_admin_report(id)
      lookup_report(id, true)
    end

    def list_all_reports(for_admin = false)
      report_lookup = {}
      DM_CONNECTIONS.databases(without_grids: true, without_system: for_admin).each do |key|
        report_lookup.merge!(get_reports_for(key, DM_CONNECTIONS.report_path(key)))
      end
      report_lookup.map { |id, lkp| { id: id, db: lkp[:db], file: lkp[:file], caption: lkp[:caption], crosstab: lkp[:crosstab], external: lkp[:external] } }
    end

    def list_all_grid_reports
      report_lookup = get_reports_for(GRID_DEFS, ENV['GRID_QUERIES_LOCATION'])
      report_lookup.map { |id, lkp| { id: id, db: lkp[:db], file: lkp[:file], caption: lkp[:caption], crosstab: lkp[:crosstab] } }
    end

    def get_reports_for(key, path) # rubocop:disable Metrics/AbcSize
      lkp = {}
      ymlfiles = File.join(path, '**', '*.yml')
      yml_list = Dir.glob(ymlfiles)

      yml_list.each do |yml_file|
        index = "#{key}_#{File.basename(yml_file).sub(File.extname(yml_file), '')}"
        yp    = Crossbeams::Dataminer::YamlPersistor.new(yml_file)
        lkp[index] = { file: yml_file, db: key, caption: Crossbeams::Dataminer::Report.load(yp).caption, crosstab: !yp.to_hash[:crosstab].nil?, external: external_render?(yp.to_hash) }
      end
      lkp
    end

    # Take a grid query definition and replace its where clause, returning the modified SQL.
    # Assumes the where clause will be of the form: "WHERE id = value", but can be modified in other ways.
    #
    # @param id [string] the query definition file name (without 'yml')
    # @param value [string, integer] the value to match.
    # @param operator [string] the operator to apply to the column. Default "=".
    # @param column [string] the column to match in the WHERE clause.
    # @param data_type [Symbol] the data_type of the column. Defaults to :integer.
    # @return [String] the SQL to be run.
    def replace_grid_query_where_clause(id, value, operator: '=', column: 'id', data_type: :integer)
      persistor = Crossbeams::Dataminer::YamlPersistor.new(File.join(ENV['GRID_QUERIES_LOCATION'], "#{id}.yml"))
      rpt = Crossbeams::Dataminer::Report.load(persistor)
      params = [Crossbeams::Dataminer::QueryParameter.new(column, Crossbeams::Dataminer::OperatorValue.new(operator, value, data_type))]
      rpt.replace_where(params)
      rpt.runnable_sql
    end

    private

    def external_render?(hash)
      return false if hash[:external_settings].nil?

      !hash[:external_settings][:render_url].nil?
    end
  end
end
