# frozen_string_literal: true

module MasterfilesApp
  UomSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:uom_type_id).filled(:integer)
    required(:uom_code).filled(Types::StrippedString)
  end
end
