# frozen_string_literal: true

module MasterfilesApp
  CUSTOMER_ROLE = 'CUSTOMER'

  class Customer < Dry::Struct
    attribute :id, Types::Integer
    attribute :party_role_id, Types::Integer
    attribute :party_name, Types::String
    attribute :customer_type_ids, Types::Array
    attribute :customer_types, Types::Array
    attribute :erp_customer_number, Types::String

    def supplier?
      false
    end
  end
end
