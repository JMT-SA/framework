# frozen_string_literal: true

module PackMaterialApp
  VehicleSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:vehicle_type_id, :integer).maybe(:int?)
    required(:vehicle_code, Types::StrippedString).maybe(:str?)
  end
end
