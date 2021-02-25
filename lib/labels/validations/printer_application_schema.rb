# frozen_string_literal: true

module LabelApp
  PrinterApplicationSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:printer_id).filled(:integer)
    required(:application).filled(Types::StrippedString)
    required(:default_printer).filled(:bool)
  end
end
