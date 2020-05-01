require 'dotenv'
require 'que'
require 'message_bus'

if ENV.fetch('RACK_ENV') == 'test'
  Dotenv.load('.env.test', '.env.local', '.env')
else
  Dotenv.load('.env.local', '.env')
end
db_name = if ENV.fetch('RACK_ENV') == 'test'
            ENV.fetch('DATABASE_URL').rpartition('/')[0..1].push(ENV.fetch('DATABASE_NAME')).push('_test').join
          else
            ENV.fetch('DATABASE_URL')
          end
require 'sequel'
require 'logger'
Sequel.extension(:pg_json_ops)
DB = Sequel.connect(db_name)
if ENV.fetch('RACK_ENV') == 'development' && !ENV['DONOTLOGSQL']
  DB.logger = if ENV['LOGSQLTOFILE']
                Logger.new('log/sql.log')
              else
                Logger.new($stdout)
              end
end
DB.extension(:connection_validator) # Ensure connections are not lost over time.
DB.extension :pg_array
DB.extension :pg_json
DB.extension :pg_hstore
DB.extension :pg_inet
Sequel.application_timezone = :local
Sequel.database_timezone = :utc

Que.connection = DB
Que.job_middleware.push(
  # ->(job, &block) {
  lambda { |job, &block|
    job.lock_single_instance
    block.call
    job.clear_single_instance
    nil # Doesn't matter what's returned.
  }
)

MessageBus.configure(backend: :postgres, backend_options: db_name)
MessageBus.configure(on_middleware_error: proc do |_env, e|
  # env contains the Rack environment at the time of error
  # e contains the exception that was raised
  raise e unless e.is_a?(Errno::EPIPE)

  # Swallow and ignore the broken pipe error for MessageBus
  [422, {}, ['']]
end)
