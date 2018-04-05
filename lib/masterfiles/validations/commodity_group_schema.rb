# frozen_string_literal: true

CommodityGroupSchema = Dry::Validation.Form do
  configure { config.type_specs = true }

  optional(:id, :int).filled(:int?)
  required(:code, Types::StrippedString).filled(:str?)
  required(:description, Types::StrippedString).filled(:str?)
  required(:active, :bool).maybe(:bool?)
end
