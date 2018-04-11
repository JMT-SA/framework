# frozen_string_literal: true

module MasterfilesApp
  TargetMarketGroupSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:target_market_group_type_id, :int).filled(:int?)
    required(:target_market_group_name, Types::StrippedString).filled(:str?)
  end
end
