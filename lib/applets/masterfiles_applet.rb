# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/masterfiles/entities/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/masterfiles/interactors/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/masterfiles/repositories/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/masterfiles/services/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/masterfiles/task_permission_checks/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/masterfiles/ui_rules/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/masterfiles/validations/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/masterfiles/views/**/*.rb"].sort.each { |f| require f }
