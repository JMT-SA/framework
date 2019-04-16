# frozen_string_literal: true

module MasterfilesApp
  LocationStorageDefinitionSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:storage_definition_code, Types::StrippedString).filled(:str?)
    required(:storage_definition_format, Types::StrippedString).filled(:str?)
    required(:storage_definition_description, Types::StrippedString).filled(:str?)
  end
end
