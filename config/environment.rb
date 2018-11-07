require 'dotenv'

if ENV.fetch('RACK_ENV') == 'test'
  Dotenv.load('.env.test', '.env')
else
  Dotenv.load('.env.local', '.env')
end
db_name = "#{ENV.fetch('DATABASE_URL')}#{'_test' if ENV.fetch('RACK_ENV') == 'test'}"

require 'sequel'
require 'logger'
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
