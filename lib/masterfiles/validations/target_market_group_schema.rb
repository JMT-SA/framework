# frozen_string_literal: true

TargetMarketGroupSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:target_market_group_type_id).filled(:int?)
  required(:target_market_group_name).filled(:str?)
end
