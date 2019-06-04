# Apply crosstab config guided by the user's chosen parameters to a Report.
#
# This will convert the Report's SQL into a Postgresql +crosstab+ function call.
class CrosstabApplier
  # @param db_connection [DB] the database connection.
  # @param report [Crossbeams::Dataminer::Report] the Report to be modified.
  # @param params [Hash] the user's parameters.
  # @param crosstab_hash [Hash] the crosstab configuration.
  def initialize(db_connection, report, params, crosstab_hash)
    @crosstab_hash = crosstab_hash
    @db_connection = db_connection
    @report        = report
    get_row_attributes(params)
    get_col_attributes(params)
    get_val_attributes(params)
  end

  # Modify a Report, changing its SQL from a standard query to a crosstab query.
  #
  # @return void.
  def convert_report
    remove_unnecessary_columns

    group_row_columns_in_array

    sql_for_column # TODO: optionally modify with where... if apply_report_where_clause is true...
    setup_crosstab_specs
    apply_new_column_fields

    @report.sql = build_crosstab_sql
    set_grouping_sequence

    set_column_attributes
  end

  private

  def get_row_attributes(params)
    @row_cols     = Array(params[:crosstab][:row_columns])
    @row_datatype = @report.columns[@row_cols.first].data_type
    @row_datatype = 'varchar' if @row_datatype == :string
  end

  def get_val_attributes(params)
    @val_col      = params[:crosstab][:value_column]
    @val_datatype = @report.columns[@val_col].data_type
  end

  def get_col_attributes(params)
    @col_col = params[:crosstab][:column_column]
  end

  def remove_unnecessary_columns
    keep_cols = @row_cols.dup
    keep_cols << @col_col
    keep_cols << @val_col
    rc = @report.columns.keys.reject { |col| keep_cols.include?(col) }
    removals = rc.map { |col| col }
    @report.remove_columns(removals) unless removals.empty?
  end

  def group_row_columns_in_array
    @report.convert_columns_to_array('row_name', @row_cols) unless @row_cols.length == 1
  end

  def sql_for_column
    this_col = @crosstab_hash[:column_columns].select { |c| c.keys.first == @col_col }.first
    @col_sql = this_col[@col_col][:sql]
  end

  def setup_crosstab_specs
    if @row_cols.length == 1
      @row_spec = @row_cols.first
      @coldef_spec = "#{@row_cols.first} #{@row_datatype}, "
    else
      i = 0
      @row_spec = @row_cols.map do |c|
        i += 1
        "row_name[#{i}] AS #{c}"
      end.join(', ')
      @coldef_spec = "row_name #{@row_datatype}[], "
    end
  end

  def apply_new_column_fields
    @col_hds  = @db_connection[@col_sql].map { |k| k.values.first }
    @col_flds = @col_hds.map { |c| "g_#{c.downcase.tr(' ', '_')}" }
    @row_spec << ", #{@col_flds.join(', ')}"
    @coldef_spec << @col_flds.map { |c| "#{c} #{@val_datatype}" }.join(', ')
  end

  def build_crosstab_sql
    base_sql = @report.runnable_sql
    <<-SQL
    SELECT #{@row_spec}
    FROM crosstab('#{base_sql.gsub("'", "''")}',
    '#{@col_sql.gsub("'", "''")}') AS
    (#{@coldef_spec})
    SQL
  end

  def set_grouping_sequence
    @row_cols[0..-2].each_with_index do |rcl, ind|
      @report.columns[rcl].group_by_seq = ind + 1
    end
  end

  def set_column_attributes
    @col_flds.each_with_index do |cfl, ind|
      @report.columns[cfl].data_type = @val_datatype.to_sym
      @report.columns[cfl].caption   = @col_hds[ind]
      @report.columns[cfl].group_sum = true
    end
  end
end
