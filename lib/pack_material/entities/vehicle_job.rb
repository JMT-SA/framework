# frozen_string_literal: true

module PackMaterialApp
  class VehicleJob < Dry::Struct
    attribute :id, Types::Integer
    attribute :business_process_id, Types::Integer
    attribute :vehicle_id, Types::Integer
    attribute :departure_location_id, Types::Integer
    attribute :tripsheet_number, Types::Integer
    attribute :planned_location_id, Types::Integer
    attribute :virtual_location_id, Types::Integer
    attribute :load_transaction_id, Types::Integer
    attribute :offload_transaction_id, Types::Integer
    attribute :when_loaded, Types::DateTime
    attribute :when_offloaded, Types::DateTime
    attribute :when_loading, Types::DateTime
    attribute :when_offloading, Types::DateTime
    attribute :loaded, Types::Bool
    attribute :offloaded, Types::Bool
    attribute :arrival_confirmed, Types::Bool
    attribute :description, Types::String
    attribute? :process, Types::String.optional
    attribute? :vehicle_code, Types::String.optional
    attribute? :departure_location_long_code, Types::String.optional
    attribute? :virtual_location_long_code, Types::String.optional
    attribute? :planned_location_long_code, Types::String.optional
  end
end
