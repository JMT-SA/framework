# frozen_string_literal: true

module PackMaterialApp
  LocationStorageTypeSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:storage_type_code, Types::StrippedString).filled(:str?)
  end
end
