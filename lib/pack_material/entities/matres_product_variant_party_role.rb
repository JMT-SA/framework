# frozen_string_literal: true

module PackMaterialApp
  class MatresProductVariantPartyRole < Dry::Struct
    attribute :id, Types::Integer
    attribute :material_resource_product_variant_id, Types::Integer
    attribute :supplier_id, Types::Integer
    attribute :customer_id, Types::Integer
    attribute :party_stock_code, Types::String
    attribute :supplier_lead_time, Types::Integer
    attribute :is_preferred_supplier, Types::Bool
    attribute :party_name, Types::String

    def supplier?
      supplier_id && true
    end
  end
end
