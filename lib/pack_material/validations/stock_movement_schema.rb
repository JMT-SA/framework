# frozen_string_literal: true

module PackMaterialApp
  StockMovementSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:start_month, Types::StrippedString).filled(:str?)
    required(:start_year, Types::StrippedString).filled(:str?)
    required(:end_date, %i[nil date]).filled(:date?)
  end
end
