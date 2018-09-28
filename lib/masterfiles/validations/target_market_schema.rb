# frozen_string_literal: true

module MasterfilesApp
  TargetMarketSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:target_market_name, Types::StrippedString).filled(:str?)
    required(:country_ids, Types::IntArray).filled { each(:int?) }
    required(:tm_group_ids, Types::IntArray).filled { each(:int?) }
  end
end
