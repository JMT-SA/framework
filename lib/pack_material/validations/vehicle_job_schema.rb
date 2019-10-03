# frozen_string_literal: true

module PackMaterialApp
  NewVehicleJobSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:business_process_id, :integer).maybe(:int?)
    required(:vehicle_id, :integer).maybe(:int?)
    required(:departure_location_id, :integer).maybe(:int?)
    # required(:tripsheet_number, :integer).maybe(:int?)
    required(:planned_location_id, :integer).maybe(:int?)
    required(:virtual_location_id, :integer).maybe(:int?)
    required(:description, Types::StrippedString).maybe(:str?)
    # required(:when_loaded, :date_time).maybe(:date_time?)
    # required(:when_offloaded, :date_time).maybe(:date_time?)
  end

  EditVehicleJobSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:business_process_id, :integer).maybe(:int?)
    required(:vehicle_id, :integer).maybe(:int?)
    required(:departure_location_id, :integer).maybe(:int?)
    # required(:tripsheet_number, :integer).maybe(:int?)
    required(:planned_location_id, :integer).maybe(:int?)
    required(:virtual_location_id, :integer).maybe(:int?)
    required(:description, Types::StrippedString).maybe(:str?)
    # required(:when_loaded, :date_time).maybe(:date_time?)
    # required(:when_offloaded, :date_time).maybe(:date_time?)
  end

  UpdateVehicleJobSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:planned_location_id, :integer).maybe(:int?)
  end
end
