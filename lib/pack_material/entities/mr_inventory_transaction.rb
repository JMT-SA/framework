# frozen_string_literal: true

module PackMaterialApp
  class MrInventoryTransaction < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_inventory_transaction_type_id, Types::Integer
    attribute :to_location_id, Types::Integer
    attribute :business_process_id, Types::Integer
    attribute :created_by, Types::String
    attribute :ref_no, Types::String
    attribute :is_adhoc, Types::Bool
  end
end
