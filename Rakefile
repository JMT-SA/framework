require 'dotenv/tasks'
require 'rake/testtask'
require 'yard'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.warning = false
  t.test_files = FileList['test/**/test_*.rb', 'lib/**/test_*.rb']
end

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = ['-', 'README.md']
  t.options = ['-o', "../docs/#{File.dirname(__FILE__).split('/').last}"]
end

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

task default: :test

namespace :db do
  desc 'Prints current schema version'
  task version: :dotenv do
    require 'sequel'
    Sequel.extension :migration
    db = Sequel.connect(ENV.fetch('FM_DATABASE_URL'))
    version = if db.tables.include?(:schema_migrations)
                db[:schema_migrations].reverse(:filename).first[:filename]
              end || 0

    puts "Schema Version: #{version}"
  end

  desc 'Prints previous 10 schema versions'
  task recent_migrations: :dotenv do
    require 'sequel'
    Sequel.extension :migration
    db = Sequel.connect(ENV.fetch('FM_DATABASE_URL'))
    migrations = if db.tables.include?(:schema_migrations)
                   db[:schema_migrations].reverse(:filename).first(10).map { |r| r[:filename] }
                 else
                   ['No migrations have been run']
                 end

    puts "Recent migrations:\n#{migrations.join("\n")}"
  end

  desc 'Run migrations'
  task :migrate, [:version] => :dotenv do |_, args|
    require 'sequel'
    Sequel.extension :migration
    db = Sequel.connect(ENV.fetch('FM_DATABASE_URL'))
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, 'db/migrations', target: args[:version].to_i)
    else
      puts 'Migrating to latest'
      Sequel::Migrator.run(db, 'db/migrations')
    end
  end

  desc 'Create a new, timestamped migration file - use NAME env var for file name suffix.'
  task :new_migration do
    nm = ENV['NAME']
    raise "\nSupply a filename (to create \"#{Time.now.strftime('%Y%m%d%H%M_create_a_table.rb')}\"):\n\n  rake #{Rake.application.top_level_tasks.last} NAME=create_a_table\n\n" if nm.nil?

    fn = Time.now.strftime("%Y%m%d%H%M_#{nm}.rb")
    File.open(File.join('db/migrations', fn), 'w') do |file|
      file.puts <<~RUBY
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
          #   drop_function(:table_name_set_created_at)
          #   drop_trigger(:table_name, :set_updated_at)
          #   drop_function(:table_name_set_updated_at)
          # end
        end
      RUBY
    end
    puts "Created migration #{fn}"
  end

  desc 'Migration to create a new table - use NAME env var for table name.'
  task :create_table_migration do
    nm = ENV['NAME']
    raise "\nYou must supply a table name - e.g. rake #{Rake.application.top_level_tasks.last} NAME=users\n\n" if nm.nil?

    fn = Time.now.strftime("%Y%m%d%H%M_create_#{nm}.rb")
    File.open(File.join('db/migrations', fn), 'w') do |file|
      file.puts <<~RUBY
        require 'sequel_postgresql_triggers'
        Sequel.migration do
          up do
            extension :pg_triggers
            create_table(:#{nm}, ignore_index_errors: true) do
              primary_key :id
              # String :code, size: 255, null: false
              # TrueClass :active, default: true
              DateTime :created_at, null: false
              DateTime :updated_at, null: false
              #
              # index [:code], name: :#{nm}_unique_code, unique: true
            end

            pgt_created_at(:#{nm},
                           :created_at,
                           function_name: :#{nm}_set_created_at,
                           trigger_name: :set_created_at)

            pgt_updated_at(:#{nm},
                           :updated_at,
                           function_name: :#{nm}_set_updated_at,
                           trigger_name: :set_updated_at)
          end

          down do
            drop_trigger(:#{nm}, :set_created_at)
            drop_function(:#{nm}_set_created_at)
            drop_trigger(:#{nm}, :set_updated_at)
            drop_function(:#{nm}_set_updated_at)
            drop_table(:#{nm})
          end
        end
      RUBY
    end
    puts "Created migration #{fn}"
  end
end

# file 'migration_new_file' do
#   # touch "db/migrate/#{Time.now.strftime('')}_mig.rb'
#   touch File.join('db/migrations', Time.now.strftime('%Y%m%d%H%M_new_migration.rb'))
# end
