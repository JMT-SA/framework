# frozen_string_literal: true

module MasterfilesApp
  LocationAssignmentSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:assignment_code).filled(Types::StrippedString)
  end
end
