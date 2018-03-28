# frozen_string_literal: true

class DataminerConnections
  attr_reader :connections
  def initialize
    @connections = {}
    configs = YAML.load_file(File.join(ENV['ROOT'], 'config', 'dataminer_connections.yml'))
    configs.each_pair do |name, config|
      # Dry Valid? && dry type?
      @connections[name] = DataminerConnection.new(name: name, connection_string: config['db'], report_path: config['path'])
    end
    @connections[ReportRepo::GRID_DEFS] = DataminerConnection.new(name: ReportRepo::GRID_DEFS, connection_string: nil, connection: DB, report_path: ENV['GRID_QUERIES_LOCATION'])
  end

  def [](key)
    connections[key].db
  end

  def report_path(key)
    connections[key].report_path
  end

  def databases(without_grids: false)
    list = connections.keys.sort
    list.delete(ReportRepo::GRID_DEFS) if without_grids
    list
  end
end

class DataminerConnection
  attr_reader :name, :report_path, :db

  ConnSchema = Dry::Validation.Schema do
    required(:name).value(format?: /\A[\da-z-]+\Z/)
    required(:connection_string).maybe
    required(:report_path).filled
    optional(:connection)
  end

  def initialize(config)
    validation = ConnSchema.call(config)
    raise %(Dataminer report config is not correct: #{validation.messages.map { |k, v| "#{k} #{v.join(', ')} (#{validation[k]})" }.join(', ')}) unless validation.success?
    @name = validation[:name]
    @report_path = Pathname.new(validation[:report_path]).expand_path
    @db = if validation[:connection_string].nil?
            validation[:connection]
          else
            Sequel.connect(validation[:connection_string])
          end
  end
end
