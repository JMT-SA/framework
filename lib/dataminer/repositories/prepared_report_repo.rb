# frozen_string_literal: true

module DataminerApp
  class PreparedReportRepo # rubocop:disable Metrics/ClassLength
    include Crossbeams::Responses

    # Get the database connection from DM_CONNECTIONS for a specific key.
    #
    # @param key [String] the database key.
    # @return [Sequel::Database] the database connection.
    def db_connection_for(key)
      DM_CONNECTIONS[key]
    end

    class ReportLocation
      attr_reader :db, :id, :path, :prepared_path, :combined

      def initialize(db_id)
        @combined = db_id
        @db = db_id.match(/\A(.+?)_/)[1]
        @id = db_id.delete_prefix("#{db}_")
        @path = DM_CONNECTIONS.report_path(db)
        @prepared_path = DM_CONNECTIONS.prepared_report_path(db)
      end
    end

    def split_db_and_id(db_id)
      rep_loc = ReportLocation.new(db_id)
      [rep_loc.db, rep_loc.id]
    end

    # Get a Report from an id.
    #
    # @param id [String] the report id.
    # @return [Crossbeams::Dataminer::Report] the report.
    def lookup_report(id)
      rep_loc = ReportLocation.new(id)
      get_report_by_id(rep_loc)
    end

    # Get a Report's crosstab configuration from an id.
    #
    # @param id [String] the report id.
    # @return [Hash] the crosstab configuration from the report's YAML definition.
    def lookup_crosstab(id)
      rep_loc = ReportLocation.new(id)
      get_report_by_id(rep_loc, crosstab_hash: true)
    end

    def lookup_file_name(id)
      rep_loc = ReportLocation.new(id)
      get_report_by_id(rep_loc, filename: true)
    end

    def load_report_dictionary(rep_loc)
      get_reports_for(rep_loc.db, rep_loc.prepared_path)
    end

    def get_report_by_id(rep_loc, opts = {})
      # config_file       = File.join(rep_loc.prepared_path, '.dm_report_list.yml')
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

    def list_all_reports(user)
      report_lookup = {}
      DM_CONNECTIONS.databases(without_grids: true).each do |key|
        report_lookup.merge!(get_reports_for(key, DM_CONNECTIONS.prepared_report_path(key), user))
      end
      # report_lookup.map { |id, lkp| { id: id, db: lkp[:db], file: lkp[:file], caption: lkp[:caption], crosstab: lkp[:crosstab] } }
      report_lookup.map { |id, lkp| { id: id, db: lkp[:db], report_name: lkp[:report_name], file: lkp[:file], caption: lkp[:caption], crosstab: lkp[:crosstab], owner: lkp[:owner] } }
    end

    def list_all_reports_for_user(user)
      report_lookup = {}
      DM_CONNECTIONS.databases(without_grids: true).each do |key|
        report_lookup.merge!(get_reports_for(key, DM_CONNECTIONS.prepared_report_path(key), user, true))
      end
      # report_lookup.map { |id, lkp| { id: id, db: lkp[:db], file: lkp[:file], caption: lkp[:caption], crosstab: lkp[:crosstab] } }
      report_lookup.map { |id, lkp| { id: id, db: lkp[:db], report_name: lkp[:report_name], file: lkp[:file], caption: lkp[:caption], crosstab: lkp[:crosstab], owner: lkp[:owner] } }
    end

    def get_reports_for(key, path, user = nil, for_user_only = false) # rubocop:disable Metrics/AbcSize
      user_id = user&.id
      lkp = {}
      yml_list = yml_files_in_path(path)

      yml_list.each do |yml_file|
        index = "#{key}_#{File.basename(yml_file).sub(File.extname(yml_file), '')}"
        yp    = Crossbeams::Dataminer::YamlPersistor.new(yml_file).to_hash
        owned_by_user = user_id.nil? ? false : File.basename(yml_file).start_with?(user_id.to_s)
        if for_user_only && !owned_by_user
          next unless yp[:external_settings][:prepared_report].key?(:linked_users) && yp[:external_settings][:prepared_report][:linked_users].include?(user_id)
        end
        lkp[index] = { file: yml_file,
                       db: key,
                       report_name: File.basename(yml_file).sub(/^\d+_/, '').sub(/_\d\d\d.yml/, ''),
                       caption: yp[:external_settings][:prepared_report][:description],
                       crosstab: !yp[:crosstab].nil?,
                       owner: owned_by_user }
      end
      lkp
    end

    def yml_files_in_path(path)
      ymlfiles = File.join(path, '**', '*.yml')
      Dir.glob(ymlfiles)
    end

    def existing_prepared_reports_for(db_id, user)
      repo = ReportRepo.new
      dbname, report_id = repo.split_db_and_id(db_id)
      path = DM_CONNECTIONS.prepared_report_path(dbname)
      list_users_prepared_reports(dbname, report_id, user, path)
    end

    def list_users_prepared_reports(dbname, report_id, user, path)
      yml_list = yml_files_in_path(path)
      yml_list.grep(%r{#{path}/#{user.id}_#{report_id}_\d\d\d.yml}).map { |p| p.sub("#{path}/", '').sub('.yml', '') }.sort.map do |rpt|
        report = lookup_report("#{dbname}_#{rpt}")
        ["#{rpt} : #{report.caption}", rpt]
      end
    end

    def create_prepared_report(user, db_id, report_description, chosen_params, existing_report)
      rep_loc = ReportLocation.new(db_id)
      rpt = ReportRepo.new.lookup_report(db_id)
      rpt.caption = report_description
      apply_prepared_report_params(rpt, user, report_description, chosen_params)
      basename = save_new_report(rpt, rep_loc, user, existing_report)
      "#{rep_loc.db}_#{basename}"
    end

    def change_columns(id, sorted_columns, hidden_columns)
      rep_loc = ReportLocation.new(id)
      report = lookup_report(id)
      sorted_columns.each_with_index do |col_name, index|
        col = report.column(col_name)
        col.hide = false
        col.sequence_no = index + 1
      end
      offset = sorted_columns.length
      hidden_columns.each_with_index do |col_name, index|
        col = report.column(col_name)
        col.hide = true
        col.sequence_no = offset + index + 1
      end
      save_file(rep_loc, report)
      success_response('Column changes have been saved')
    end

    def save_file(rep_loc, report)
      filename = File.join(rep_loc.prepared_path, "#{rep_loc.id}.yml")
      persistor = Crossbeams::Dataminer::YamlPersistor.new(filename)
      report.save(persistor)
    end

    def save_prepared_report(id, params)
      rep_loc = ReportLocation.new(id)
      rpt = lookup_report(id)
      rpt.caption = params[:report_description]
      rpt.external_settings[:prepared_report][:report_description] = params[:report_description]
      rpt.external_settings[:prepared_report][:linked_users] = (params[:linked_users] || []).map(&:to_i)

      save_file(rep_loc, rpt)
    end

    def apply_prepared_report_params(rpt, user, report_description, chosen_params)
      rpt.external_settings[:prepared_report] = {}
      rpt.external_settings[:prepared_report][:description] = report_description
      rpt.external_settings[:prepared_report][:user] = user.id
      rpt.external_settings[:prepared_report][:created_on] = Time.now.strftime('%F %R')
      rpt.external_settings[:prepared_report][:json_var] = chosen_params
    end

    def save_new_report(rpt, rep_loc, user, existing_report)
      new_basename = new_prepared_report_file(user, rep_loc.id, rep_loc.prepared_path, existing_report)
      new_filename = File.join(rep_loc.prepared_path, "#{new_basename}.yml")
      persistor = Crossbeams::Dataminer::YamlPersistor.new(new_filename)
      rpt.save(persistor)

      new_basename
    end

    def new_prepared_report_file(user, id, prepared_path, existing_report)
      return existing_report unless existing_report.nil? || existing_report&.blank?

      prefix = "#{user.id}_#{id}"
      "#{prefix}_#{next_seq_no(prepared_path, prefix).to_s.rjust(3, '0')}"
    end

    def next_seq_no(prepared_path, prefix)
      hold_dir = Dir.pwd

      Dir.chdir(prepared_path)
      files = Dir.glob("#{prefix}_*")
      sequences = files.grep(/#{prefix}_\d+.yml/).map { |a| a.sub("#{prefix}_", '').sub('.yml', '').to_i }.sort
      next_or_re_use_missing_seq(sequences)
    ensure
      Dir.chdir(hold_dir)
    end

    # Get the next available sequence from a sorted array of integers.
    # Return 1 If the list is empty.
    # If there are gaps in the sequence, return the lowest available gap number.
    # Otherwise return the number after the maximum sequence number.
    def next_or_re_use_missing_seq(sequences)
      1.step.find { |int| !sequences.include?(int) }
    end
  end
end
