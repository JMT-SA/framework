# frozen_string_literal: true

module MasterfilesApp
  class TmGroupType < Dry::Struct
    attribute :id, Types::Int
    attribute :target_market_group_type_code, Types::String
  end
end
