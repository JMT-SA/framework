# frozen_string_literal: true

module PackMaterialApp
  class VehicleJobUnit < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_sku_location_from_id, Types::Integer
    attribute :mr_inventory_transaction_item_id, Types::Integer
    attribute :vehicle_job_id, Types::Integer
    attribute :quantity_to_move, Types::Decimal
    attribute :when_loaded, Types::DateTime
    attribute :when_offloaded, Types::DateTime
    attribute :when_offloading, Types::DateTime
    attribute :quantity_moved, Types::Decimal
    attribute :when_loading, Types::DateTime
  end
end
