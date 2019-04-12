# frozen_string_literal: true

module MasterfilesApp
  LocationSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:primary_storage_type_id, :integer).filled(:int?)
    required(:location_type_id, :integer).filled(:int?)
    required(:primary_assignment_id, :integer).filled(:int?)
    required(:location_storage_definition_id, :integer).maybe(:int?)
    required(:location_long_code, Types::StrippedString).filled(:str?)
    required(:location_description, Types::StrippedString).filled(:str?)
    required(:location_short_code, Types::StrippedString).filled(:str?)
    required(:print_code, Types::StrippedString).maybe(:str?)
    required(:has_single_container, :bool).maybe(:bool?)
    required(:virtual_location, :bool).maybe(:bool?)
    required(:consumption_area, :bool).maybe(:bool?)
    optional(:can_be_moved, :bool).maybe(:bool?)
    required(:can_store_stock, :bool).maybe(:bool?)
  end
end
