# frozen_string_literal: true

class DataminerConnections
  attr_reader :connections
  def initialize
    @connections = {}
    configs = YAML.load_file(File.join(ENV['ROOT'], 'config', 'dataminer_connections.yml'))
    configs.each_pair do |name, config|
      # Dry Valid? && dry type?
      @connections[name] = DataminerConnection.new(name: name,
                                                   connection_string: config['db'],
                                                   report_path: config['path'],
                                                   prepared_report_path: config['prepared_path'])
    end
    @connections[DataminerApp::ReportRepo::GRID_DEFS] = DataminerConnection.new(name: DataminerApp::ReportRepo::GRID_DEFS,
                                                                                connection_string: nil,
                                                                                connection: DB,
                                                                                report_path: ENV['GRID_QUERIES_LOCATION'],
                                                                                prepared_report_path: ENV['GRID_QUERIES_LOCATION'])
  end

  def config(key)
    connections[key]
  end

  def [](key)
    connections[key].db
  end

  def report_path(key)
    connections[key].report_path
  end

  def prepared_report_path(key)
    connections[key].prepared_report_path
  end

  def databases(without_grids: false, without_system: false)
    list = connections.keys.sort
    list.delete(DataminerApp::ReportRepo::GRID_DEFS) if without_grids
    list.delete('system') if without_system && !AppConst.development?
    list
  end

  # Disconnect all DB connections
  def disconnect_all
    connections.each { |_, conn| conn.disconnect }
  end
end

class DataminerConnection
  attr_reader :name, :report_path, :prepared_report_path, :db,
              :connected, :connection_error

  ConnSchema = Dry::Schema.Params do
    required(:name).value(:string, format?: /\A[\da-z-]+\Z/)
    required(:connection_string).maybe(:string)
    required(:report_path).filled(:string)
    required(:prepared_report_path).filled(:string)
    optional(:connection).value(type?: Sequel::Postgres::Database) # Possibly not neccessary...
  end

  def initialize(config) # rubocop:disable Metrics/AbcSize
    @connected = false
    validation = ConnSchema.call(config)
    # raise %(Dataminer report config is not correct: #{validation.messages.map { |k, v| "#{k} #{v.join(', ')}" }.join(', ')}) unless validation.success?
    raise %(Dataminer report config is not correct: #{validation.errors.to_h.map { |k, v| "#{k} #{v.join(', ')}" }.join(', ')}) unless validation.success?

    @name = validation[:name]
    @report_path = Pathname.new(validation[:report_path]).expand_path
    @prepared_report_path = Pathname.new(validation[:prepared_report_path]).expand_path
    @db = if validation[:connection_string].nil?
            validation[:connection]
          else
            # Sequel.connect(validation[:connection_string], after_connect: ->(_) { p 'CONNECTED' })
            Sequel.connect(validation[:connection_string])
          end
    # Ensure connections are not lost over time.
    @db.extension(:connection_validator) unless validation[:connection_string].nil?
    @connected = true
  rescue Sequel::DatabaseConnectionError => e
    @connection_error = e.message
  end

  def disconnect
    @db.disconnect
  end
end
