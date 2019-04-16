# frozen_string_literal: true

module MasterfilesApp
  class LocationStorageDefinition < Dry::Struct
    attribute :id, Types::Integer
    attribute :storage_definition_code, Types::String
    attribute :storage_definition_format, Types::String
    attribute :storage_definition_description, Types::String
    attribute :active, Types::Bool
  end
end
