# frozen_string_literal: true

module MasterfilesApp
  MarketingVarietySchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:marketing_variety_code).filled(Types::StrippedString)
    required(:description).maybe(Types::StrippedString)
  end
end
