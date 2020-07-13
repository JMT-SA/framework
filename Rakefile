# require 'dotenv/tasks'
require 'rake/testtask'
require 'rake/clean'
require 'yard'
require 'rubocop/rake_task'
require 'crossbeams/menu_migrations'

Dir['./lib/tasks/**/*.rake'].sort.each { |ext| load ext }

Rake::TestTask.new(:test) do |t|
  if ENV['TEST'] == 'test/**/*_test.rb'
    ENV['TEST'] = nil
    p 'Discarding TEST env var setting - using Rake task file list.'
  end
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

namespace :assets do
  desc 'Precompile the assets'
  task :precompile do
    require_relative 'config/environment'
    require './webapp'
    Framework.compile_assets
  end
  CLEAN << 'prestyle.css'
end

# This task ensures Local .env is considered if present:
task :dotenv_with_override do
  require 'dotenv'
  Dotenv.load('.env.local', '.env')
end

# This task ensures the app is loaded.
task load_app: [:dotenv_with_override] do
  require './app_loader'
end

namespace :jobs do
  # Can be used in cron: @reboot sleep 60 &&  cd /home/nsld/pack_materials/current && chruby-exec 2.5.0 -- bundle exec rake jobs:restart_screen
  desc 'Restart que process running in screen session'
  task restart_screen: [:dotenv_with_override] do
    ruby_ver = ENV.fetch('CHRUBY_STRING')
    queue = ENV.fetch('QUEUE_NAME')
    session_name = "#{queue}_que"
    log_name = File.join(__dir__, 'log', 'que.log')
    part1 = "screen -S #{session_name} -X quit"
    part2 = "cd #{__dir__} && screen -dmS #{session_name} bash -c 'source /usr/local/share/chruby/chruby.sh && chruby #{ruby_ver} && RACK_ENV=production bundle exec que -q #{queue} ./app_loader.rb >> #{log_name} 2>&1'"
    # `#{part1} ; #{part2}`
    # `{ #{part1} ; #{part2} }`
    `#{part1}`
    `#{part2}`
  end
end

namespace :menu do
  desc 'Run menu migrations'
  task :migrate, [:version] => :dotenv_with_override do |_, args|
    require 'sequel'
    db_name = if ENV.fetch('RACK_ENV') == 'test'
                ENV.fetch('DATABASE_URL').rpartition('/')[0..1].push(ENV.fetch('DATABASE_NAME')).push('_test').join
              else
                ENV.fetch('DATABASE_URL')
              end
    db = Sequel.connect(db_name)
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Crossbeams::MenuMigrations::Migrator.run(db, 'db/menu', args[:version].to_i)
    else
      puts 'Migrating to latest'
      Crossbeams::MenuMigrations::Migrator.run(db, 'db/menu')
    end
  end

  desc 'Rollback one menu migration'
  task rollback: :dotenv_with_override do
    require 'sequel'
    db_name = if ENV.fetch('RACK_ENV') == 'test'
                ENV.fetch('DATABASE_URL').rpartition('/')[0..1].push(ENV.fetch('DATABASE_NAME')).push('_test').join
              else
                ENV.fetch('DATABASE_URL')
              end
    db = Sequel.connect(db_name)
    migrations = if db.tables.include?(:menu_migrations)
                   db[:menu_migrations].reverse(:filename).first(2).map { |r| r[:filename] }
                 else
                   'No migrations have been run'
                 end
    if migrations.is_a? String
      puts "Unable to rollback - #{migrations}"
    else
      puts "Migrating to version #{migrations.last}"
      Crossbeams::MenuMigrations::Migrator.run(db, 'db/menu', migrations.last.to_i)
    end
  end

  desc 'Create a new, timestamped migration file - use NAME env var for file name suffix.'
  task :new_migration do
    nm = ENV['NAME']
    raise "\nSupply a filename (to create \"#{Time.now.strftime('%Y%m%d%H%M_create_a_table.rb')}\"):\n\n  rake #{Rake.application.top_level_tasks.last} NAME=create_a_table\n\n" if nm.nil?

    fn = Time.now.strftime("%Y%m%d%H%M_#{nm}.rb")
    File.open(File.join('db/menu', fn), 'w') do |file|
      file.puts <<~RUBY
        Crossbeams::MenuMigrations::Migrator.migration('Framework') do
          up do
          end

          down do
          end
        end
      RUBY
    end
    puts "Created migration #{fn}"
  end
end

namespace :db do
  desc 'Add a new user'
  task :add_user, %i[login_name password user_name] => [:dotenv_with_override] do |_, args|
    require 'bcrypt'
    raise "\nLogin name cannot include spaces.\n\n" if args[:login_name].include?(' ')

    pwd_hash = args[:password]
    pwd_hash = BCrypt::Password.create(pwd_hash) unless BCrypt::Password.valid_hash?(pwd_hash)

    require 'sequel'
    db_name = if ENV.fetch('RACK_ENV') == 'test'
                ENV.fetch('DATABASE_URL').rpartition('/')[0..1].push(ENV.fetch('DATABASE_NAME')).push('_test').join
              else
                ENV.fetch('DATABASE_URL')
              end
    db = Sequel.connect(db_name)
    id = db[:users].insert(login_name: args[:login_name], user_name: args[:user_name], password_hash: pwd_hash)
    puts "Created user with id #{id}"
  end

  desc 'Prints current schema version'
  task version: :dotenv_with_override do
    require 'sequel'
    Sequel.extension :migration
    db_name = if ENV.fetch('RACK_ENV') == 'test'
                ENV.fetch('DATABASE_URL').rpartition('/')[0..1].push(ENV.fetch('DATABASE_NAME')).push('_test').join
              else
                ENV.fetch('DATABASE_URL')
              end
    db = Sequel.connect(db_name)
    version = if db.tables.include?(:schema_migrations)
                db[:schema_migrations].reverse(:filename).first[:filename]
              else
                0
              end

    puts "Schema Version: #{version}"
  end

  desc 'Prints previous 10 schema versions'
  task recent_migrations: :dotenv_with_override do
    require 'sequel'
    Sequel.extension :migration
    db_name = if ENV.fetch('RACK_ENV') == 'test'
                ENV.fetch('DATABASE_URL').rpartition('/')[0..1].push(ENV.fetch('DATABASE_NAME')).push('_test').join
              else
                ENV.fetch('DATABASE_URL')
              end
    db = Sequel.connect(db_name)
    migrations = if db.tables.include?(:schema_migrations)
                   db[:schema_migrations].reverse(:filename).first(10).map { |r| r[:filename] }
                 else
                   ['No migrations have been run']
                 end

    puts "Recent migrations:\n#{migrations.join("\n")}"
  end

  desc 'Apply db seeds to masterfiles'
  task mf_seeds: :dotenv_with_override do
    require 'sequel'
    db_name = if ENV.fetch('RACK_ENV') == 'test'
                ENV.fetch('DATABASE_URL').rpartition('/')[0..1].push(ENV.fetch('DATABASE_NAME')).push('_test').join
              else
                ENV.fetch('DATABASE_URL')
              end
    db = Sequel.connect(db_name)
    db.run(File.read('./db/seeds/20_masterfile_data.sql'))
    puts 'Masterfile seeds applied'
  end

  desc 'Run migrations'
  task :migrate, [:version] => :dotenv_with_override do |_, args|
    require 'sequel'
    Sequel.extension :migration
    db_name = if ENV.fetch('RACK_ENV') == 'test'
                ENV.fetch('DATABASE_URL').rpartition('/')[0..1].push(ENV.fetch('DATABASE_NAME')).push('_test').join
              else
                ENV.fetch('DATABASE_URL')
              end
    db = Sequel.connect(db_name)
    db.extension :pg_timestamptz
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, 'db/migrations', target: args[:version].to_i)
    else
      puts 'Migrating to latest'
      if ENV['MISS']
        Sequel::Migrator.run(db, 'db/migrations', allow_missing_migration_files: true)
      else
        Sequel::Migrator.run(db, 'db/migrations')
      end
    end
  end

  desc 'Rollback one migration'
  task rollback: :dotenv_with_override do
    require 'sequel'
    Sequel.extension :migration
    db_name = if ENV.fetch('RACK_ENV') == 'test'
                ENV.fetch('DATABASE_URL').rpartition('/')[0..1].push(ENV.fetch('DATABASE_NAME')).push('_test').join
              else
                ENV.fetch('DATABASE_URL')
              end
    db = Sequel.connect(db_name)
    db.extension :pg_timestamptz
    migrations = if db.tables.include?(:schema_migrations)
                   db[:schema_migrations].reverse(:filename).first(2).map { |r| r[:filename] }
                 else
                   'No migrations have been run'
                 end
    if migrations.is_a? String
      puts "Unable to rollback - #{migrations}"
    else
      puts "Migrating to version #{migrations.last}"
      Sequel::Migrator.run(db, 'db/migrations', target: migrations.last.to_i)
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
            # create_table(:table_name, ignore_index_errors: true) do
            #   primary_key :id
            #   foreign_key :some_id, :some_table_name, null: false, key: [:id]
            #
            #   String :my_uniq_name, null: false
            #   String :user_name
            #   String :password_hash, null: false
            #   String :email
            #   TrueClass :active, default: true
            #   DateTime :created_at, null: false
            #   DateTime :updated_at, null: false

            #   index [:some_id], name: :fki_table_name_some_table_name
            #   index [:my_uniq_name], name: :table_name_unique_my_uniq_name, unique: true
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
              # foreign_key :some_id, :some_table_name, null: false, key: [:id]
              # String :code, null: false
              # String :remarks, text: true
              # BigDecimal :quantity_type, size: [12,2]
              # BigDecimal :price_type, size: [17,5]
              # TrueClass :other_bool, default: false
              # TrueClass :active, default: true
              # DateTime :other
              DateTime :created_at, null: false
              DateTime :updated_at, null: false

              # index [:code], name: :#{nm}_unique_code, unique: true
              # index [:some_id], name: :fki_#{nm}_some_table_name
            end

            pgt_created_at(:#{nm},
                           :created_at,
                           function_name: :#{nm}_set_created_at,
                           trigger_name: :set_created_at)

            pgt_updated_at(:#{nm},
                           :updated_at,
                           function_name: :#{nm}_set_updated_at,
                           trigger_name: :set_updated_at)

            # Log changes to this table. Exclude changes to the updated_at column.
            run "SELECT audit.audit_table('#{nm}', true, true, '{updated_at}'::text[]);"
          end

          down do
            # Drop logging for this table.
            drop_trigger(:#{nm}, :audit_trigger_row)
            drop_trigger(:#{nm}, :audit_trigger_stm)

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
