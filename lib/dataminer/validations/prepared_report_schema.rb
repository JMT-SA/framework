# frozen_string_literal: true

module DataminerApp
  PreparedReportSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    required(:report_description, Types::StrippedString).filled(:str?)
  end
end
