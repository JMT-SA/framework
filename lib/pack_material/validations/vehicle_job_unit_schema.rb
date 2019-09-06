# frozen_string_literal: true

module PackMaterialApp
  VehicleJobUnitSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_sku_location_from_id, :integer).maybe(:int?)
    required(:mr_inventory_transaction_item_id, :integer).maybe(:int?)
    required(:vehicle_job_id, :integer).maybe(:int?)
    required(:quantity_to_move, :decimal).maybe(:decimal?)
    required(:when_loaded, :date_time).maybe(:date_time?)
    required(:when_offloaded, :date_time).maybe(:date_time?)
    required(:when_offloading, :date_time).maybe(:date_time?)
    required(:quantity_moved, :decimal).maybe(:decimal?)
    required(:when_loading, :date_time).maybe(:date_time?)
  end
end
