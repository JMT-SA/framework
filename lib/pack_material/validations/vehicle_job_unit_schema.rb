# frozen_string_literal: true

module PackMaterialApp
  class NewVehicleJobUnitContract < Dry::Validation::Contract
    params do
      optional(:id).filled(:integer)
      required(:vehicle_job_id).maybe(:integer)
      required(:available_quantity).maybe(:decimal, gt?: 0)
      required(:quantity_to_move).maybe(:decimal, gt?: 0)
      required(:mr_sku_id).maybe(:integer)
      # required(:sku_number).maybe(:integer)
      required(:location_id).maybe(:integer)
    end

    rule(:quantity_to_move, :available_quantity) do
      key.failure('must be less than or equal to available quantity') unless values[:available_quantity] >= values[:quantity_to_move]
    end
    # configure do
    #   config.type_specs = true
    #
    #   def self.messages
    #     super.merge(en: { errors: { valid_quantity: 'Quantity to move must be less than or equal to available quantity' } })
    #   end
    # end

    # optional(:id, :integer).filled(:int?)
    # required(:vehicle_job_id, :integer).maybe(:int?)
    # required(:available_quantity, :decimal).maybe(:decimal?, gt?: 0)
    # required(:quantity_to_move, :decimal).maybe(:decimal?, gt?: 0)
    # required(:mr_sku_id, :integer).maybe(:int?)
    # # required(:sku_number, :integer).maybe(:int?)
    # required(:location_id, :integer).maybe(:int?)
    #
    # validate(valid_quantity: %i[available_quantity quantity_to_move]) do |available_quantity, quantity_to_move|
    #   available_quantity >= quantity_to_move
    # end
  end

  VehicleJobUnitSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:vehicle_job_id).maybe(:integer)
    required(:quantity_to_move).maybe(:decimal)
    required(:when_loaded).maybe(:date_time)
    required(:when_offloaded).maybe(:date_time)
    required(:when_offloading).maybe(:date_time)
    required(:quantity_loaded).maybe(:decimal)
    required(:quantity_offloaded).maybe(:decimal)
    required(:when_loading).maybe(:date_time)
    required(:mr_sku_id).maybe(:integer)
    required(:sku_number).maybe(:integer)
    required(:location_id).maybe(:integer)
  end

  VehicleJobUnitInlineSchema = Dry::Schema.Params do
    required(:column_name).filled(Types::StrippedString)
    required(:column_value).maybe(:decimal, gt?: 0)
  end

  VehicleJobUnitLoadingSchema = Dry::Schema.Params do
    required(:tripsheet_number).filled(:integer)
    required(:tripsheet_number_scan_field).maybe(Types::StrippedString)
    required(:location).filled(Types::StrippedString)
    required(:location_scan_field).maybe(Types::StrippedString)
    required(:sku_number).filled(:integer)
    required(:sku_number_scan_field).maybe(Types::StrippedString)
    required(:quantity).filled(:decimal, gt?: 0)
  end
end
