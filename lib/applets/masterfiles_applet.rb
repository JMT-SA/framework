# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/masterfiles/entities/*.rb"].each { |f| require f }
Dir["#{root_dir}/masterfiles/interactors/*.rb"].each { |f| require f }
Dir["#{root_dir}/masterfiles/repositories/*.rb"].each { |f| require f }
Dir["#{root_dir}/masterfiles/services/*.rb"].each { |f| require f }
Dir["#{root_dir}/masterfiles/task_permission_checks/*.rb"].each { |f| require f }
Dir["#{root_dir}/masterfiles/ui_rules/*.rb"].each { |f| require f }
Dir["#{root_dir}/masterfiles/validations/*.rb"].each { |f| require f }
Dir["#{root_dir}/masterfiles/views/**/*.rb"].each { |f| require f }
