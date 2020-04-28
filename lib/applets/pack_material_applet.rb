# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/pack_material/entities/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/pack_material/interactors/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/pack_material/jobs/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/pack_material/modules/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/pack_material/repositories/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/pack_material/services/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/pack_material/task_permission_checks/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/pack_material/ui_rules/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/pack_material/validations/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/pack_material/views/**/*.rb"].sort.each { |f| require f }

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
