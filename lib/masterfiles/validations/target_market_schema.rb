# frozen_string_literal: true

TargetMarketSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:target_market_name).filled(:str?)
end
