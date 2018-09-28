# frozen_string_literal: true

module MasterfilesApp
  # SUPPLIER_ROLE = 'SUPPLIER'

  class Supplier < Dry::Struct
    attribute :id, Types::Integer
    attribute :party_role_id, Types::Integer
    attribute :erp_supplier_number, Types::String
  end

  class SupplierWithName < Dry::Struct
    attribute :id, Types::Integer
    attribute :party_role_id, Types::Integer
    attribute :party_name, Types::String
    # attribute :role_type, Types::String.default(SUPPLIER_ROLE)
    attribute :role_type, Types::String
    attribute :supplier_type_ids, Types::Array
    attribute :supplier_types, Types::Array
    attribute :erp_supplier_number, Types::String
  end
end
