# frozen_string_literal: true

NewReportSchema = Dry::Validation.Form do
  optional(:database).filled(:str?)
  required(:filename).filled(:str?)
  required(:caption).filled(:str?)
  required(:sql).filled(:str?)
end
