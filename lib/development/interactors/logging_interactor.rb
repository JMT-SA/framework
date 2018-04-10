# frozen_string_literal: true

module DevelopmentApp
  class LoggingInteractor < BaseInteractor
    def repo
      @repo ||= LoggingRepo.new
    end

    def exists?(entity, id)
      # repo = RepoBase.new
      repo.exists?(entity, event_id: id)
    end

    def logged_action_detail(cached = true)
      if cached
        @logged_action_detail ||= repo.find_logged_action_detail(@id)
      else
        @logged_action_detail = repo.find_logged_action_detail(@id)
      end
    end

    def logged_actions_grid(id)
      logged_action = repo.find_logged_action(id)
      row_defs = []
      row_defs << current_action_data_record(logged_action.table_name.to_sym, logged_action.row_data_id)
      logged_action_changes(logged_action.table_name, logged_action.row_data_id).each { |c| row_defs << c }

      {
        columnDefs: col_defs_for_logged_actions(logged_action),
        rowDefs:    row_defs
      }.to_json
    end

    private

    def col_defs_for_logged_actions(logged_action)
      col_names = DevelopmentRepo.new.table_col_names(logged_action.table_name)
      col_defs = [{ headerName: 'Action Time', field: 'action_tstamp_tx' },
                  { headerName: 'Action', field: 'action' },
                  { headerName: 'User', field: 'user_name', width: 200 },
                  { headerName: 'Context', field: 'context' },
                  { headerName: 'Status', field: 'status' }]
      col_defs += make_columns_for(col_names, logged_action.table_name)
      col_defs << { headerName: 'Stmt Only?', field: 'statement_only',
                    cellRenderer: 'crossbeamsGridFormatters.booleanFormatter',
                    cellClass:    'grid-boolean-column',
                    width:        100 }
      col_defs
    end

    def current_action_data_record(table_name, row_data_id)
      data_record = repo.find_hash(table_name.to_sym, row_data_id) || {}
      data_record[:context] = data_record.empty? ? 'DELETED' : 'CURRENT'
      data_record[:action_tstamp_tx] = Time.now
      data_record[:action] = 'N/A'
      data_record
    end

    def make_columns_for(col_names, table_name)
      col_lookup = Hash[DevelopmentRepo.new.table_columns(table_name)]
      cols = []

      col_names.each do |name|
        coldef = col_lookup[name]
        cols << col_with_attrs(coldef, name)
      end
      cols
    end

    def col_with_attrs(coldef, name)
      inflector = Dry::Inflector.new
      col = { headerName: inflector.humanize(name), field: name }
      numeric_col_attrs(col, coldef) if %i[integer decimal float].include?(coldef[:type])
      col[:cellRenderer] = 'crossbeamsGridFormatters.numberWithCommas4' if %i[decimal float].include?(coldef[:type])
      boolean_col_attrs(col) if coldef[:type] == :boolean
      col
    end

    def numeric_col_attrs(col, coldef)
      col[:cellClass] = 'grid-number-column'
      col[:width]     = 100 if coldef[:type] == :integer
      col[:width]     = 120 if coldef[:type] == :number
    end

    def boolean_col_attrs(col)
      col[:cellRenderer] = 'crossbeamsGridFormatters.booleanFormatter'
      col[:cellClass]    = 'grid-boolean-column'
      col[:width]        = 100
    end

    def logged_action_changes(table_name, id)
      rows = []
      repo.logged_actions_for_id(table_name, id).each do |row|
        row_data = row.delete(:row_data)
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
