# frozen_string_literal: true

module MasterfilesApp
  ContactMethodSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:contact_method_type_id).filled(:integer)
    required(:contact_method_code).filled(Types::StrippedString)
    # required(:active).filled(:bool)
  end
end
