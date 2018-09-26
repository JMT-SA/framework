# frozen_string_literal: true

module MasterfilesApp
  class Supplier < Dry::Struct
    attribute :id, Types::Int
    attribute :party_role_id, Types::Int
    attribute :erp_supplier_number, Types::String
  end

  class SupplierWithName < Dry::Struct
    attribute :id, Types::Int
    attribute :party_role_id, Types::Int
    attribute :party_name, Types::String
    attribute :role_type, Types::String
    attribute :supplier_type_ids, Types::Array
    attribute :supplier_types, Types::Array
    attribute :erp_supplier_number, Types::String
  end
end
