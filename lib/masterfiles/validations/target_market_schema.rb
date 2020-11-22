# frozen_string_literal: true

module MasterfilesApp
  TargetMarketSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:target_market_name).filled(Types::StrippedString)
    required(:country_ids).filled(:array).each(:integer)
    required(:tm_group_ids).filled(:array).each(:integer)
  end
end
