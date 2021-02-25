# frozen_string_literal: true

module PackMaterialApp
  VehicleSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:vehicle_type_id).maybe(:integer)
    required(:vehicle_code).maybe(Types::StrippedString)
  end
end
