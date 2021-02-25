# frozen_string_literal: true

module MasterfilesApp
  TmGroupTypeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:target_market_group_type_code).filled(Types::StrippedString)
  end
end
