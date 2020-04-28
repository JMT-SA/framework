# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/pack_material/entities/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/interactors/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/jobs/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/modules/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/repositories/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/services/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/task_permission_checks/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/ui_rules/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/validations/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/views/**/*.rb"].each { |f| require f }

module PackMaterialApp
  DOMAIN_NAME = 'Pack Material'

  TRANSACTION_TYPE_CREATE_STOCK = 'CREATE STOCK'
  TRANSACTION_TYPE_PUTAWAY = 'PUTAWAY'
  TRANSACTION_TYPE_ADHOC_MOVE = 'ADHOC MOVE'
  TRANSACTION_TYPE_REMOVE_STOCK = 'REMOVE STOCK'
  TRANSACTION_TYPE_LOAD_VEHICLE = 'LOAD VEHICLE'
  TRANSACTION_TYPE_OFFLOAD_VEHICLE = 'OFFLOAD VEHICLE'

  INVENTORY_UOM_TYPE = 'INVENTORY'
end
