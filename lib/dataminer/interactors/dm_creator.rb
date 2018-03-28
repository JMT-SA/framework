class DmCreator
  attr_reader :report, :db

  def initialize(db, report)
    @db     = db
    @report = report
  end

  def modify_column_datatypes
    column_names.each do |name|
      report.columns[name].data_type = column_datatypes[name]
      report.columns[name].groupable = groupable?(column_datatypes[name], name)
      report.columns[name].format    = :delimited_1000 if column_datatypes[name] == :number
    end
    report
  end

  private

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
    @datatypes ||= begin
      tables       = report.tables
      # puts ">>> #{tables.inspect}"
      column_types = {}
      tables.each do |table|
        # puts ">>> TABLE: #{table}"
        db.schema(table.sub('public.', '')).each do |col| # NB problem if another schema used... ... db.connection == Sequel.connection from ROM.
          # puts ">>> COL: #{col}"
          type = col[1][:type]
          column_types[col.first.to_s] = case type # translate into :number etc...
                                         when :decimal, :float
                                           :number
                                         else
                                           type
                                         end
          # Check types with DB.schema('parties_roles').map {|c| c[1][:type] }.compact.uniq.sort
          # :boolean, :date, :datetime, :decimal, :float, :integer, :string
        end
      end
      column_types
    end
  end
end
