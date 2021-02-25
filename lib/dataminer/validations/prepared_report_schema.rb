# frozen_string_literal: true

module DataminerApp
  PreparedReportSchema = Dry::Schema.Params do
    required(:report_description).filled(Types::StrippedString)
    optional(:existing_report).maybe(Types::StrippedString)
    optional(:linked_users).maybe(:array).maybe { each(:integer) }
  end
end
