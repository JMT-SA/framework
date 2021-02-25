# frozen_string_literal: true

module DevelopmentApp
  AddressTypeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:address_type).filled(Types::StrippedString)
  end
end
