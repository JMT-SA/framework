# frozen_string_literal: true

MarketingVarietySchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:marketing_variety_code).filled(:str?)
  required(:description).maybe(:str?)
end
