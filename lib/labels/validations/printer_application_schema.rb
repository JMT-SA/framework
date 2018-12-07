# frozen_string_literal: true

module LabelApp
  PrinterApplicationSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:printer_id, :integer).filled(:int?)
    required(:application, Types::StrippedString).filled(:str?)
  end
end
