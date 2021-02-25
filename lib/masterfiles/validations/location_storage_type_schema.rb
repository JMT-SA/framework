# frozen_string_literal: true

module MasterfilesApp
  LocationStorageTypeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:storage_type_code).filled(Types::StrippedString)
    required(:location_short_code_prefix).maybe(Types::StrippedString)
  end
end
