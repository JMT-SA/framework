# frozen_string_literal: true

module MasterfilesApp
  PartySchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:party_type).filled(Types::StrippedString, max_size?: 1)
    required(:active).filled(:bool)
  end
end
