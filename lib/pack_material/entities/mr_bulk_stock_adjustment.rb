# frozen_string_literal: true

module PackMaterialApp
  class MrBulkStockAdjustment < Dry::Struct
    attribute :id, Types::Integer
    attribute :stock_adjustment_number, Types::Integer
    attribute :create_transaction_id, Types::Integer
    attribute :destroy_transaction_id, Types::Integer
    attribute :business_process_id, Types::Integer
    attribute :is_stock_take, Types::Bool
    attribute :completed, Types::Bool
    attribute :approved, Types::Bool
    attribute :signed_off, Types::Bool
    attribute :active, Types::Bool
    attribute :ref_no, Types::StrippedString
  end
end
