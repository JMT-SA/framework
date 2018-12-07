# frozen_string_literal: true

root_dir = File.expand_path('../..', __FILE__)
Dir["#{root_dir}/labels/entities/*.rb"].each { |f| require f }
Dir["#{root_dir}/labels/interactors/*.rb"].each { |f| require f }
Dir["#{root_dir}/labels/repositories/*.rb"].each { |f| require f }
# Dir["#{root_dir}/labels/services/*.rb"].each { |f| require f }
Dir["#{root_dir}/labels/ui_rules/*.rb"].each { |f| require f }
Dir["#{root_dir}/labels/validations/*.rb"].each { |f| require f }
Dir["#{root_dir}/labels/views/**/*.rb"].each { |f| require f }

module LabelApp
end
