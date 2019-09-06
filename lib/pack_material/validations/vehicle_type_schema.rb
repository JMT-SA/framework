# frozen_string_literal: true

module PackMaterialApp
  VehicleTypeSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:type_code, Types::StrippedString).maybe(:str?)
  end
end
