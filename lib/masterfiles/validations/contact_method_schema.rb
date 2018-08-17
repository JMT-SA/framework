# frozen_string_literal: true

module MasterfilesApp
  ContactMethodSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:contact_method_type_id, :int).filled(:int?)
    required(:contact_method_code, Types::StrippedString).filled(:str?)
    required(:active, :bool).filled(:bool?)
  end
end
