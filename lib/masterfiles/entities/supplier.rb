# frozen_string_literal: true

module MasterfilesApp
  class Supplier < Dry::Struct
    attribute :id, Types::Int
    attribute :party_role_id, Types::Int
    attribute :supplier_type_id, Types::Int
    attribute :erp_supplier_number, Types::String
  end
end
