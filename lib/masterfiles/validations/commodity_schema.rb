# frozen_string_literal: true

CommoditySchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:commodity_group_id).filled(:int?)
  required(:code).filled(:str?)
  required(:description).filled(:str?)
  required(:hs_code).filled(:str?)
  required(:active).maybe(:bool?)
end
