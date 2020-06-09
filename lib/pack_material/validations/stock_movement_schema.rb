# frozen_string_literal: true

module PackMaterialApp
  StockMovementSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:start_date, Types::Date).filled(:date?)
    required(:end_date, Types::Date).filled(:date?)
  end
end
