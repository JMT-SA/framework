# frozen_string_literal: true

module MasterfilesApp
  NewCustomerSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:party_id).filled(:integer)
    required(:customer_type_ids).filled(:array).each(:integer)
    required(:erp_customer_number).maybe(Types::StrippedString)
  end

  EditCustomerSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:customer_type_ids).filled(:array).each(:integer)
    required(:erp_customer_number).maybe(Types::StrippedString)
  end
end
