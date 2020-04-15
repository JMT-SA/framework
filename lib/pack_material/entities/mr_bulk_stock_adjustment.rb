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
    attribute :carton_assembly, Types::Bool
    attribute :staging_consumption, Types::Bool
    attribute :integration_error, Types::Bool
    attribute :integration_completed, Types::Bool
    attribute :integrated_at, Types::DateTime
    attribute :active, Types::Bool
    attribute :ref_no, Types::StrippedString
    attribute :erp_depreciation_number, Types::StrippedString
    attribute :status, Types::String
  end
end
