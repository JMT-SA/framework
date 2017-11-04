root_dir = File.expand_path('../..', __FILE__)
Dir["#{root_dir}/development/entities/*.rb"].each { |f| require f }
Dir["#{root_dir}/development/interactors/*.rb"].each { |f| require f }
Dir["#{root_dir}/development/repositories/*.rb"].each { |f| require f }
Dir["#{root_dir}/development/services/*.rb"].each { |f| require f }
Dir["#{root_dir}/development/ui_rules/*.rb"].each { |f| require f }
Dir["#{root_dir}/development/validations/*.rb"].each { |f| require f }
Dir["#{root_dir}/development/views/**/*.rb"].each { |f| require f }
