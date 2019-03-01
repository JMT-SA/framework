# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/pack_material/entities/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/interactors/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/jobs/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/repositories/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/services/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/task_permission_checks/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/ui_rules/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/validations/*.rb"].each { |f| require f }
Dir["#{root_dir}/pack_material/views/**/*.rb"].each { |f| require f }

module PackMaterialApp
  DOMAIN_NAME = 'Pack Material'

  DEFAULT_RECEIVING_BAY_NAME = 'RECEIVING BAY'
  # LABEL_RECEIVING_BAY_NAME = 'LABEL RECEIVING BAY'
  # NOTE: This needs to be physically set up

  TRANSACTION_TYPE_CREATE_STOCK = 'CREATE STOCK'
  TRANSACTION_TYPE_PUTAWAY = 'PUTAWAY'
  TRANSACTION_TYPE_ADHOC_MOVE = 'ADHOC MOVE'
  TRANSACTION_TYPE_REMOVE_STOCK = 'REMOVE STOCK'
end
