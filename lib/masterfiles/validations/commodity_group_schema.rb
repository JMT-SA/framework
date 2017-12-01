# frozen_string_literal: true

CommodityGroupSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:code).filled(:str?)
  required(:description).filled(:str?)
  required(:active).maybe(:bool?)
end
