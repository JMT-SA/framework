# frozen_string_literal: true

module DevelopmentApp
  AddressTypeSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:address_type, Types::StrippedString).filled(:str?)
    required(:active, :bool).maybe(:bool?)
  end
end
