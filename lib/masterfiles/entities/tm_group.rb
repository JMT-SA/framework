# frozen_string_literal: true

module MasterfilesApp
  class TmGroup < Dry::Struct
    attribute :id, Types::Integer
    attribute :target_market_group_type_id, Types::Integer
    attribute :target_market_group_name, Types::String
  end
end
