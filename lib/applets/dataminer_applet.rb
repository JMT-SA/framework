# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/dataminer/entities/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/dataminer/interactors/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/dataminer/repositories/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/dataminer/ui_rules/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/dataminer/validations/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/dataminer/views/**/*.rb"].sort.each { |f| require f }

module DataminerApp
end
