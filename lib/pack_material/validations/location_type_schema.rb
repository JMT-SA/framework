# frozen_string_literal: true

module PackMaterialApp
  LocationTypeSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:location_type_code, Types::StrippedString).filled(:str?)
  end
end
