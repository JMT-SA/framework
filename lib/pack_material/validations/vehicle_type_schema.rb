# frozen_string_literal: true

module PackMaterialApp
  VehicleTypeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:type_code).maybe(Types::StrippedString)
  end
end
