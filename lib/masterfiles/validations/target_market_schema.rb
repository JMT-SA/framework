# frozen_string_literal: true

TargetMarketSchema = Dry::Validation.Form do
  configure { config.type_specs = true }

  optional(:id, :int).filled(:int?)
  required(:target_market_name, Types::StrippedString).filled(:str?)
end
