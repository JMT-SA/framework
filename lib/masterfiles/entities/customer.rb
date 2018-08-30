# frozen_string_literal: true

module MasterfilesApp
  class Customer < Dry::Struct
    attribute :id, Types::Int
    attribute :party_role_id, Types::Int
    attribute :customer_type_id, Types::Int
    attribute :erp_customer_number, Types::String
  end
end
