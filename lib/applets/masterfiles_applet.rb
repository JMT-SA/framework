root_dir = File.expand_path('../..', __FILE__)
Dir["#{root_dir}/masterfiles/entities/*.rb"].each { |f| require f }
Dir["#{root_dir}/masterfiles/interactors/*.rb"].each { |f| require f }
Dir["#{root_dir}/masterfiles/repositories/*.rb"].each { |f| require f }
Dir["#{root_dir}/masterfiles/ui_rules/*.rb"].each { |f| require f }
Dir["#{root_dir}/masterfiles/validations/*.rb"].each { |f| require f }
Dir["#{root_dir}/masterfiles/views/**/*.rb"].each { |f| require f }
Dir["#{root_dir}/masterfiles/interactors/**/*.rb"].each { |f| require f }
