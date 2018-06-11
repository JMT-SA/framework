# frozen_string_literal: true

module DataminerApp
  PreparedReportSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    required(:report_description, Types::StrippedString).filled(:str?)
    optional(:existing_report, Types::StrippedString).maybe(:str?)
    optional(:linked_users, Types::IntArray).maybe { each(:int?) }
  end
end
