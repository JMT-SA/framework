# frozen_string_literal: true

module DevelopmentApp
  ContactMethodTypeSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:contact_method_type, Types::StrippedString).filled(:str?)
    required(:active, :bool).filled(:bool?)
  end
end
