# frozen_string_literal: true

module DataminerApp
  NewReportSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:database, Types::StrippedString).filled(:str?)
    required(:filename, Types::StrippedString).filled(:str?)
    required(:caption, Types::StrippedString).filled(:str?)
    required(:sql, :string).filled(:str?)
  end
end
