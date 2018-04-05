# frozen_string_literal: true

MarketingVarietySchema = Dry::Validation.Form do
  configure { config.type_specs = true }

  optional(:id, :int).filled(:int?)
  required(:marketing_variety_code, Types::StrippedString).filled(:str?)
  required(:description, Types::StrippedString).maybe(:str?)
end
