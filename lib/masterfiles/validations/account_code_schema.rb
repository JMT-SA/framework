# frozen_string_literal: true

module MasterfilesApp
  AccountCodeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:account_code).filled(:integer)
    required(:description).filled(Types::StrippedString)
  end
end
