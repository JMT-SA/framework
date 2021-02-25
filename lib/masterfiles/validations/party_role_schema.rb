# frozen_string_literal: true

module MasterfilesApp
  PartyRoleSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:party_id).filled(:integer)
    required(:role_id).filled(:integer)
    required(:organization_id).maybe(:integer)
    required(:person_id).maybe(:integer)
    required(:active).filled(:bool)
  end
end
