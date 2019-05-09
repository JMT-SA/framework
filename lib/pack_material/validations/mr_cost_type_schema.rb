# frozen_string_literal: true

module PackMaterialApp
  MrCostTypeSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:cost_type_code, Types::StrippedString).maybe(:str?)
  end
end
