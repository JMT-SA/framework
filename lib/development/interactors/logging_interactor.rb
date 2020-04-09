# frozen_string_literal: true

module DevelopmentApp
  class LoggingInteractor < BaseInteractor # rubocop:disable Metrics/ClassLength
    def repo
      @repo ||= LoggingRepo.new
    end

    def exists?(entity, id)
      repo.exists?(entity, event_id: id)
    end

    def logged_actions_grid(id)
      logged_action = repo.find_logged_action(id)
      row_defs = []
      row_defs << current_action_data_record(logged_action.table_name.to_sym, logged_action.row_data_id)
      logged_action_changes(logged_action.table_name, logged_action.row_data_id).each { |c| row_defs << c }

      {
        columnDefs: col_defs_for_logged_actions(logged_action),
        rowDefs: row_defs
      }.to_json
    end

    def diff_action(id, from_status_log: false)
      logged_action = if from_status_log
                        repo.find_logged_action_hash_from_status_log(id)
                      else
                        repo.find_logged_action_hash(id)
                      end
      return [] if logged_action.nil?

      left = Sequel.hstore(logged_action[:row_data]).to_hash
      right = changed_fields_for_right(logged_action)
      [diff_with_excluded_fields(left), diff_with_excluded_fields(right)]
    end

    def transaction_sql(id)
      repo.logged_actions_sql_for_transaction(id)
    end

    private

    def changed_fields_for_right(logged_action)
      if logged_action[:changed_fields].nil?
        Sequel.hstore(logged_action[:row_data]).to_hash
      else
        Sequel.hstore(logged_action[:row_data]).to_hash.merge(Sequel.hstore(logged_action[:changed_fields]).to_hash)
      end
    end

    def diff_with_excluded_fields(hash)
      hash.reject { |k, _| AppConst::FIELDS_TO_EXCLUDE_FROM_DIFF.include?(k) }
    end

    def col_defs_for_logged_actions(logged_action) # rubocop:disable Metrics/AbcSize
      col_names = DevelopmentRepo.new.table_col_names(logged_action.table_name)
      Crossbeams::DataGrid::ColumnDefiner.new.make_columns do |mk|
        mk.action_column do |act|
          act.popup_link 'Detail diff', '/development/logging/logged_actions/$col1$/diff',
                         col1: 'event_id',
                         icon: 'list',
                         title: 'View differences',
                         hide_if_null: :event_id
        end
        mk.col 'action_tstamp_tx', 'Action time'
        mk.col 'action'
        mk.col 'user_name', 'User', width: 200
        mk.col 'context'
        mk.col 'route_url'
        mk.col 'request_ip'
        make_columns_for(col_names, logged_action.table_name).each do |col|
          mk.col col[:field], nil, col[:options]
        end
        mk.boolean 'statement_only', 'Stmt only?'
        mk.integer 'event_id'
        mk.integer 'id', nil, hide: true
      end
    end

    def current_action_data_record(table_name, row_data_id)
      data_record = repo.find_hash(table_name.to_sym, row_data_id) || {}
      data_record[:context] = data_record.empty? ? 'DELETED' : 'CURRENT'
      data_record[:action_tstamp_tx] = Time.now
      data_record[:action] = 'N/A'
      data_record[:event_id] = nil
      data_record[:id] = 1
      data_record
    end

    def make_columns_for(col_names, table_name)
      col_lookup = Hash[DevelopmentRepo.new.table_columns(table_name)]
      cols = []

      col_names.each do |name|
        coldef = col_lookup[name]
        cols << col_with_attrs(coldef, name == :id ? 'rowid' : name)
      end
      cols
    end

    def col_with_attrs(coldef, name)
      col = { field: name }
      opts = {}
      opts[:data_type] = :string
      opts[:data_type] = :integer if coldef[:type] == :integer
      opts[:data_type] = :number if %i[decimal float].include?(coldef[:type])
      opts[:format]    = :delimited_1000 if %i[decimal float].include?(coldef[:type])
      opts[:data_type] = :boolean if coldef[:type] == :boolean
      col.merge(options: opts)
    end

    def logged_action_changes(table_name, id)
      rows = []
      repo.logged_actions_for_id(table_name, id).each do |row|
        row_data = row.delete(:row_data)
        row_data[:rowid] = row_data.delete(:id) # Rename id column to prevent uniqueness problems in the grid.
        changed_fields = row.delete(:changed_fields)
        rows << if changed_fields.nil?
                  row.merge(Sequel.hstore(row_data).to_hash)
                else
                  row.merge(Sequel.hstore(changed_fields).to_hash)
                end
      end
      rows
    end
  end
end
