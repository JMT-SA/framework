# frozen_string_literal: true

module MasterfilesApp
  CommoditySchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:commodity_group_id).filled(:integer)
    required(:code).filled(Types::StrippedString)
    required(:description).filled(Types::StrippedString)
    required(:hs_code).filled(Types::StrippedString)
    # required(:active).filled(:bool)
  end
end
