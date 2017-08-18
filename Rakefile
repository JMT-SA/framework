require "dotenv/tasks"

namespace :db do
  desc "Run migrations"
  task :migrate, [:version] => :dotenv do |t, args|
    require "sequel"
    Sequel.extension :migration
    db = Sequel.connect(ENV.fetch("FM_DATABASE_URL"))
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, "db/migrations", target: args[:version].to_i)
    else
      puts "Migrating to latest"
      Sequel::Migrator.run(db, "db/migrations")
    end
  end

  desc "Create a new, timestamped migration file. Use NAME env var for file name suffix."
  task :new_migration do
    nm = ENV['NAME']
    fail "\nSupply a filename (to create \"#{Time.now.strftime('%Y%m%d%H%M_create_a_table.rb')}\"):\n\n  rake #{Rake.application.top_level_tasks.last} NAME=create_a_table\n\n" if nm.nil?
    # puts "GOT: #{nm}"
    # touch File.join('db/migrations', Time.now.strftime("%Y%m%d%H%M_#{nm}.rb"))
    File.open(File.join('db/migrations', Time.now.strftime("%Y%m%d%H%M_#{nm}.rb")), 'w') do |file|
      file.puts <<~EOS
      # require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
      Sequel.migration do
        change do
          # Example for create table:
          # create_table(:users, ignore_index_errors: true) do
          #   primary_key :id
          #   String :login_name, size: 255, null: false
          #   String :user_name, size: 255
          #   String :password_hash, size: 255, null: false
          #   String :email, size: 255
          #   TrueClass :active, default: true
          #   DateTime :created_at, null: false
          #   DateTime :updated_at, null: false
          #   
          #   index [:login_name], name: :users_unique_login_name, unique: true
          # end
        end
        # Example for setting up created_at and updated_at timestamp triggers:
        # (Change table_name to the actual table name).
        # up do
        #   extension :pg_triggers

        #   pgt_created_at(:table_name,
        #                  :created_at,
        #                  function_name: :table_name_set_created_at,
        #                  trigger_name: :set_created_at)

        #   pgt_updated_at(:table_name,
        #                  :updated_at,
        #                  function_name: :table_name_set_updated_at,
        #                  trigger_name: :set_updated_at)
        # end

        # down do
        #   drop_trigger(:table_name, :set_created_at)
        #   drop_function(:table_name)
        #   drop_trigger(:table_name, :set_updated_at)
        #   drop_function(:table_name)
        # end
      end
      EOS
    end
  end
end

# file 'migration_new_file' do
#   # touch "db/migrate/#{Time.now.strftime('')}_mig.rb'
#   touch File.join('db/migrations', Time.now.strftime('%Y%m%d%H%M_new_migration.rb'))
# end
