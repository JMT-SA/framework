# frozen_string_literal: true

module MasterfilesApp
  StandardPackCodeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:standard_pack_code).filled(Types::StrippedString)
  end
end
