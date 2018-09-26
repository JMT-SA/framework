# frozen_string_literal: true

module MasterfilesApp
  # CUSTOMER_ROLE = 'CUSTOMER'

  class Customer < Dry::Struct
    attribute :id, Types::Int
    attribute :party_role_id, Types::Int
    attribute :erp_customer_number, Types::String
  end

  class CustomerWithName < Dry::Struct
    attribute :id, Types::Int
    attribute :party_role_id, Types::Int
    attribute :party_name, Types::String
    attribute :role_type, Types::String
    # attribute :role_type, Types::String.default(CUSTOMER_ROLE)
    attribute :customer_type_ids, Types::Array
    attribute :customer_types, Types::Array
    attribute :erp_customer_number, Types::String
  end
end
