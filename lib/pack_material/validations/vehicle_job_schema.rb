# frozen_string_literal: true

module PackMaterialApp
  NewVehicleJobSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:business_process_id).maybe(:integer)
    required(:vehicle_id).maybe(:integer)
    required(:departure_location_id).maybe(:integer)
    # required(:tripsheet_number).maybe(:integer)
    required(:planned_location_id).maybe(:integer)
    required(:virtual_location_id).maybe(:integer)
    required(:description).maybe(Types::StrippedString)
    # required(:when_loaded).maybe(:date_time)
    # required(:when_offloaded).maybe(:date_time)
  end

  EditVehicleJobSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:business_process_id).maybe(:integer)
    required(:vehicle_id).maybe(:integer)
    required(:departure_location_id).maybe(:integer)
    # required(:tripsheet_number).maybe(:integer)
    required(:planned_location_id).maybe(:integer)
    required(:virtual_location_id).maybe(:integer)
    required(:description).maybe(Types::StrippedString)
    # required(:when_loaded).maybe(:date_time)
    # required(:when_offloaded).maybe(:date_time)
  end

  UpdateVehicleJobSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:planned_location_id).maybe(:integer)
  end
end
