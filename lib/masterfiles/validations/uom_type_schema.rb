# frozen_string_literal: true

module MasterfilesApp
  UomTypeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:code).filled(Types::StrippedString)
  end
end
