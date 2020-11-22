# frozen_string_literal: true

module PackMaterialApp
  MrCostTypeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:cost_type_code).filled(Types::StrippedString)
    required(:account_code).filled(Types::StrippedString)
  end
end
