# frozen_string_literal: true

module MasterfilesApp
  class MarketingVariety < Dry::Struct
    attribute :id, Types::Integer
    attribute :marketing_variety_code, Types::String
    attribute :description, Types::String
  end
end
