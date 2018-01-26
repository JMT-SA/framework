# frozen_string_literal: true

root_dir = File.expand_path('../..', __FILE__)
Dir["#{root_dir}/settings/entities/*.rb"].each { |f| require f }
Dir["#{root_dir}/settings/interactors/*.rb"].each { |f| require f }
Dir["#{root_dir}/settings/repositories/*.rb"].each { |f| require f }
# Dir["#{root_dir}/settings/services/*.rb"].each { |f| require f }
Dir["#{root_dir}/settings/ui_rules/*.rb"].each { |f| require f }
Dir["#{root_dir}/settings/validations/*.rb"].each { |f| require f }
Dir["#{root_dir}/settings/views/**/*.rb"].each { |f| require f }
