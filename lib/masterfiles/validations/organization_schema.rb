# frozen_string_literal: true

module MasterfilesApp
  OrganizationSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    optional(:parent_id).maybe(:integer)
    required(:short_description).filled(Types::StrippedString)
    required(:medium_description).filled(Types::StrippedString)
    required(:long_description).maybe(Types::StrippedString)
    required(:vat_number).maybe(Types::StrippedString)
    required(:role_ids).filled(:array).each(:integer)
  end
end
