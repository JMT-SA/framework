# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/rmd/entities/*.rb"].each { |f| require f }
Dir["#{root_dir}/rmd/interactors/*.rb"].each { |f| require f }
Dir["#{root_dir}/rmd/repositories/*.rb"].each { |f| require f }
Dir["#{root_dir}/rmd/ui_rules/*.rb"].each { |f| require f }
Dir["#{root_dir}/rmd/validations/*.rb"].each { |f| require f }
Dir["#{root_dir}/rmd/views/**/*.rb"].each { |f| require f }

module RmdApp
end
