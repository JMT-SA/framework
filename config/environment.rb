require 'dotenv'

Dotenv.load('.env.local', '.env')
db_name = "#{ENV.fetch('DATABASE_URL')}#{'_test' if ENV.fetch('RACK_ENV') == 'test'}"

require 'sequel'
require 'logger'
DB = Sequel.connect(db_name)
DB.logger = Logger.new($stdout) if ENV.fetch('RACK_ENV') == 'development' && !ENV['DONOTLOGSQL']
# DB.logger = Logger.new('log/sql.log') if ENV.fetch('RACK_ENV') == 'development' && !ENV['DONOTLOGSQL']
DB.extension :pg_array
DB.extension :pg_json
