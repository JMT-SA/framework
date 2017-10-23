require 'dotenv'

Dotenv.load('.env.local', '.env')

require 'sequel'
DB = Sequel.connect(ENV.fetch('FM_DATABASE_URL'))
DB.extension :pg_array
