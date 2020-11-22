# frozen_string_literal: true

module DevelopmentApp
  ContactMethodTypeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:contact_method_type).filled(Types::StrippedString)
  end
end
