# frozen_string_literal: true

module PackMaterialApp
  class MrSalesReturnItem < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_sales_return_id, Types::Integer
    attribute :mr_sales_order_item_id, Types::Integer
    attribute :remarks, Types::String
    attribute :quantity_returned, Types::Decimal
  end

  class MrSalesReturnItemFlat < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_sales_return_id, Types::Integer
    attribute :mr_sales_order_item_id, Types::Integer
    attribute :sales_return_number, Types::Integer
    attribute :remarks, Types::String
    attribute :quantity_returned, Types::Decimal
    attribute :quantity_required, Types::Decimal
    attribute :unit_price, Types::Decimal
    attribute :product_variant_code, Types::String
    attribute :created_at, Types::DateTime
    attribute :updated_at, Types::DateTime
    attribute :created_by, Types::String
    attribute :status, Types::String
  end
end
