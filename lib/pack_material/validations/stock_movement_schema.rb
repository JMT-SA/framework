# frozen_string_literal: true

module PackMaterialApp
  StockMovementSchema = Dry::Schema.Params do
    required(:start_month).filled(Types::StrippedString)
    required(:start_year).filled(Types::StrippedString)
    required(:end_date).filled(%i[nil date])
  end
end
