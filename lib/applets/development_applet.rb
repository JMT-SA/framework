# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/development/entities/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/development/interactors/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/development/jobs/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/development/repositories/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/development/services/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/development/ui_rules/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/development/validations/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/development/views/**/*.rb"].sort.each { |f| require f }

module DevelopmentApp
end
