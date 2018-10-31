# frozen_string_literal: true

module PackMaterialApp
  class MrVatType < Dry::Struct
    attribute :id, Types::Integer
    attribute :vat_type_code, Types::String
    attribute :percentage_applicable, Types::Decimal
    attribute :vat_not_applicable, Types::Bool
  end
end
