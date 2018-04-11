# frozen_string_literal: true

module MasterfilesApp
  CommoditySchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:commodity_group_id, :int).filled(:int?)
    required(:code, Types::StrippedString).filled(:str?)
    required(:description, Types::StrippedString).filled(:str?)
    required(:hs_code, Types::StrippedString).filled(:str?)
    required(:active, :bool).maybe(:bool?)
  end
end
