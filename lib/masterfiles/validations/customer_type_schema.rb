# frozen_string_literal: true

module MasterfilesApp
  CustomerTypeSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:type_code, Types::StrippedString).filled(:str?)
  end
end
