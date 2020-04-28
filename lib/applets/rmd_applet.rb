# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/rmd/entities/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/rmd/interactors/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/rmd/repositories/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/rmd/ui_rules/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/rmd/validations/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/rmd/views/**/*.rb"].sort.each { |f| require f }

module RmdApp
end
