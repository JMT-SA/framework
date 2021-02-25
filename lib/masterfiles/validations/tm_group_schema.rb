# frozen_string_literal: true

module MasterfilesApp
  TmGroupSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:target_market_group_type_id).filled(:integer)
    required(:target_market_group_name).filled(Types::StrippedString)
  end
end
