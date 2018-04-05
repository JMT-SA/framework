# frozen_string_literal: true

module DevelopmentApp
  ContactMethodTypeSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:contact_method_type, Types::StrippedString).filled(:str?)
  end
end
