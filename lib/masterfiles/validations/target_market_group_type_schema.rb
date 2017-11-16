# frozen_string_literal: true

TargetMarketGroupTypeSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:target_market_group_type_code).filled(:str?)
end
