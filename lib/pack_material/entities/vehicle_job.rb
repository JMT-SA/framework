# frozen_string_literal: true

module PackMaterialApp
  class VehicleJob < Dry::Struct
    attribute :id, Types::Integer
    attribute :business_process_id, Types::Integer
    attribute :vehicle_id, Types::Integer
    attribute :departure_location_id, Types::Integer
    attribute :tripsheet_number, Types::Integer
    attribute :planned_location_id, Types::Integer
    attribute :when_loaded, Types::DateTime
    attribute :when_offloaded, Types::DateTime
    attribute? :process, Types::String.optional
    attribute? :vehicle_code, Types::String.optional
    attribute? :departure_location_long_code, Types::String.optional
    attribute? :planned_location_long_code, Types::String.optional
    attribute :loaded, Types::Bool
    attribute :offloaded, Types::Bool
    attribute :load_transaction_id, Types::Integer
    attribute :putaway_transaction_id, Types::Integer
    attribute :offload_transaction_id, Types::Integer
  end
end
