# frozen_string_literal: true

module PackMaterialApp
  class MrSkuLocation < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_sku_id, Types::Integer
    attribute :location_id, Types::Integer
    attribute :quantity, Types::Decimal
  end
end
