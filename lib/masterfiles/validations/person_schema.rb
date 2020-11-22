# frozen_string_literal: true

module MasterfilesApp
  PersonSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:surname).filled(Types::StrippedString)
    required(:first_name).filled(Types::StrippedString)
    required(:title).filled(Types::StrippedString)
    required(:vat_number).maybe(Types::StrippedString)
    required(:role_ids).filled(:array).each(:integer)
    # required(:active).filled(:bool)
  end
end
