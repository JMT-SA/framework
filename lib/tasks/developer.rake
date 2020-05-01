# frozen_string_literal: true

require File.expand_path('../../config/env_var_rules.rb', __dir__)
require File.expand_path('../../helpers/utility_functions.rb', __dir__)

# Rake tasks for setting up development environment.
class AppDevTasks
  include Rake::DSL

  def initialize # rubocop:disable Metrics/AbcSize
    namespace :developers do
      desc 'Create or update .env.local and copy ".example" files'
      task :setup do
        @logs = []
        puts '1. Mail settings'
        setup_mail_settings
        puts ''
        puts '2. Dataminer settings'
        setup_dm_settings
        puts ''
        puts '3. Environment variables'
        setup_env
        puts '4. Required paths'
        prep_required_paths
        @logs.unshift "\n----------" unless @logs.empty?
        @logs.push '----------' unless @logs.empty?
        puts @logs.join("\n") unless @logs.empty?
      end

      desc 'List of ENV variables'
      task :listenv do
        EnvVarRules.new.print
      end

      desc 'Validate presence of ENV variables'
      task :validateenv do
        EnvVarRules.new.validate
      end

      desc 'Clear the SQL log file'
      namespace :log do
        task :clear do
          fn = 'log/sql.log'
          if File.exist?(fn)
            file = File.new(fn)
            puts "SQL log file is #{UtilityFunctions.filesize(file.size)} in size.\nTruncating."
          else
            puts 'No SQL log file. Creating.'
          end
          `cat /dev/null > #{fn}`
        end
      end
    end
  end

  def root_path
    @root_path ||= File.expand_path('../..', __dir__)
  end

  def log(msg)
    @logs << msg
  end

  def setup_mail_settings
    example = File.join(root_path, 'config', 'mail_settings.rb.example')
    target = File.join(root_path, 'config', 'mail_settings.rb')
    return unless File.exist?(example) && !File.exist?(target)

    copy(example, target)
    log "Please configure mail settings in #{target}"
  end

  def setup_dm_settings
    example = File.join(root_path, 'config', 'dataminer_connections.yml.example')
    target = File.join(root_path, 'config', 'dataminer_connections.yml')
    return unless File.exist?(example) && !File.exist?(target)

    copy(example, target)
    log "Please configure dataminer settings in #{target}"
  end

  def setup_env
    target = File.join(root_path, '.env.local')
    FileUtils.touch(target) unless File.exist?(target)

    EnvVarRules.new.add_missing_to_local
  end

  def prep_required_paths
    linked_dirs = %w[log tmp public/assets public/tempfiles public/downloads/jasper prepared_reports].map do |path|
      File.join(root_path, path)
    end
    paths = FileUtils.mkdir_p(linked_dirs)
    log 'Setting up paths:'
    paths.each { |p| log p }
  end

  def copy(from, to)
    puts "...Copying #{from} to #{to}."
    FileUtils.copy(from, to)
  end
end

AppDevTasks.new
