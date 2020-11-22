# frozen_string_literal: true

module MasterfilesApp
  CustomerTypeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:type_code).filled(Types::StrippedString)
  end
end
