# frozen_string_literal: true

module MasterfilesApp
  LocationSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:primary_storage_type_id).filled(:integer)
    required(:location_type_id).filled(:integer)
    required(:primary_assignment_id).filled(:integer)
    required(:location_storage_definition_id).maybe(:integer)
    required(:location_long_code).filled(Types::StrippedString)
    required(:location_description).filled(Types::StrippedString)
    required(:location_short_code).filled(Types::StrippedString)
    required(:print_code).maybe(Types::StrippedString)
    required(:has_single_container).maybe(:bool)
    required(:virtual_location).maybe(:bool)
    required(:consumption_area).maybe(:bool)
    optional(:can_be_moved).maybe(:bool)
    required(:can_store_stock).maybe(:bool)
  end
end
