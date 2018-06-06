# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/dataminer/entities/*.rb"].each { |f| require f }
Dir["#{root_dir}/dataminer/interactors/*.rb"].each { |f| require f }
Dir["#{root_dir}/dataminer/repositories/*.rb"].each { |f| require f }
Dir["#{root_dir}/dataminer/ui_rules/*.rb"].each { |f| require f }
Dir["#{root_dir}/dataminer/validations/*.rb"].each { |f| require f }
Dir["#{root_dir}/dataminer/views/**/*.rb"].each { |f| require f }

module DataminerApp
end
