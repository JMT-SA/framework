# frozen_string_literal: true

module DataminerApp
  NewReportSchema = Dry::Schema.Params do
    optional(:database).filled(Types::StrippedString)
    required(:filename).filled(Types::StrippedString)
    required(:caption).filled(Types::StrippedString)
    required(:sql).filled(:string)
  end
end
