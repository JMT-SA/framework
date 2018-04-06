class DmCreator
  attr_reader :report, :db

  def initialize(db_conn, report)
    @db     = db_conn
    @report = report
  end

  def modify_column_datatypes
    column_names.each do |name|
      column_attributes_for(report.columns, name)
    end
    report
  end

  private

  def column_attributes_for(columns, name)
    columns[name].data_type = column_datatypes[name]
    columns[name].groupable = groupable?(column_datatypes[name], name)
    columns[name].format    = :delimited_1000 if column_datatypes[name] == :number
  end

  def column_names
    report.columns.keys.reject { |name| column_datatypes[name].nil? }
  end

  def groupable?(data_type, name)
    case data_type
    when :boolean
      true
    when :string
      true
    when :integer
      !name.end_with?('_id')
    when :number
      true
    else
      false
    end
  end

  def column_datatypes
    @column_datatypes ||= begin
      column_types = {}
      report.tables.each do |full_table_name|
        add_column_types_for(full_table_name, column_types)
      end
      column_types
    end
  end

  def add_column_types_for(full_table_name, column_types)
    schema, table = split_schema_table(full_table_name)
    db.schema(db.from(Sequel[schema][table])).each do |col|
      column_types[col.first.to_s] = make_type(col[1][:type])
    end
  end

  def make_type(type)
    if %i[decimal float].include?(type)
      :number
    else
      type
    end
  end

  def split_schema_table(full_table_name)
    ar = full_table_name.split('.')
    table = ar.delete_at(-1)
    schema = ar.first || 'public'
    [schema.to_sym, table]
  end
end
