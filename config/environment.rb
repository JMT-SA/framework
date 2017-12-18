require 'dotenv'

Dotenv.load('.env.local', '.env')
db_name = "#{ENV.fetch('FM_DATABASE_URL')}#{'_test' if ENV.fetch('RACK_ENV') == 'test'}"

require 'sequel'
DB = Sequel.connect(db_name)
DB.extension :pg_array
