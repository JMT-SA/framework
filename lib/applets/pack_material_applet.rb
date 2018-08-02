# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/pack_material/entities/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/interactors/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/repositories/*.rb"].each { |f| require f }
# Dir["#{root_dir}/pack_material/services/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/ui_rules/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/validations/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/views/**/*.rb"].each { |f| require f }

module PackMaterialApp
  DOMAIN_NAME = 'Pack Material'
end
