# frozen_string_literal: true

module MasterfilesApp
  LocationTypeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:location_type_code).filled(Types::StrippedString)
    required(:short_code).filled(Types::StrippedString)
    required(:can_be_moved).filled(:bool)
  end
end
