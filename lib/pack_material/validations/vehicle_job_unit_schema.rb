# frozen_string_literal: true

module PackMaterialApp
  NewVehicleJobUnitSchema = Dry::Validation.Params do
    configure do
      config.type_specs = true

      def self.messages
        super.merge(en: { errors: { valid_quantity: 'Quantity to move must be less than or equal to available quantity' } })
      end
    end

    optional(:id, :integer).filled(:int?)
    required(:vehicle_job_id, :integer).maybe(:int?)
    required(:available_quantity, :decimal).maybe(:decimal?, gt?: 0)
    required(:quantity_to_move, :decimal).maybe(:decimal?, gt?: 0)
    required(:mr_sku_id, :integer).maybe(:int?)
    # required(:sku_number, :integer).maybe(:int?)
    required(:location_id, :integer).maybe(:int?)

    validate(valid_quantity: %i[available_quantity quantity_to_move]) do |available_quantity, quantity_to_move|
      available_quantity >= quantity_to_move
    end
  end

  VehicleJobUnitSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:vehicle_job_id, :integer).maybe(:int?)
    required(:quantity_to_move, :decimal).maybe(:decimal?)
    required(:when_loaded, :date_time).maybe(:date_time?)
    required(:when_offloaded, :date_time).maybe(:date_time?)
    required(:when_offloading, :date_time).maybe(:date_time?)
    required(:quantity_loaded, :decimal).maybe(:decimal?)
    required(:quantity_offloaded, :decimal).maybe(:decimal?)
    required(:when_loading, :date_time).maybe(:date_time?)
    required(:mr_sku_id, :integer).maybe(:int?)
    required(:sku_number, :integer).maybe(:int?)
    required(:location_id, :integer).maybe(:int?)
  end

  VehicleJobUnitInlineSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:column_name, Types::StrippedString).filled(:str?)
    required(:column_value, :decimal).maybe(:decimal?, gt?: 0)
  end

  VehicleJobUnitLoadingSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:tripsheet_number, :integer).filled(:int?)
    required(:tripsheet_number_scan_field, Types::StrippedString).maybe(:str?)
    required(:location, Types::StrippedString).filled(:str?)
    required(:location_scan_field, Types::StrippedString).maybe(:str?)
    required(:sku_number, :integer).filled(:int?)
    required(:sku_number_scan_field, Types::StrippedString).maybe(:str?)
    required(:quantity, :decimal).filled(:decimal?, gt?: 0)
  end
end
