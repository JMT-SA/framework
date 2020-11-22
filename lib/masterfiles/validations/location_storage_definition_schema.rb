# frozen_string_literal: true

module MasterfilesApp
  LocationStorageDefinitionSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:storage_definition_code).filled(Types::StrippedString)
    required(:storage_definition_format).filled(Types::StrippedString)
    required(:storage_definition_description).filled(Types::StrippedString)
  end
end
