# frozen_string_literal: true

module MasterfilesApp
  AddressSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:address_type_id).filled(:integer)
    required(:address_line_1).filled(Types::StrippedString)
    required(:address_line_2).maybe(Types::StrippedString)
    required(:address_line_3).maybe(Types::StrippedString)
    required(:city).maybe(Types::StrippedString)
    required(:postal_code).maybe(Types::StrippedString)
    required(:country).maybe(Types::StrippedString)
    # required(:active).filled(:bool)
  end
end
