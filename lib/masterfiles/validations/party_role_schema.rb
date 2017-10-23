# frozen_string_literal: true

PartyRoleSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:party_id).filled(:int?)
  required(:role_id).filled(:int?)
  required(:organization_id).maybe(:int?)
  required(:person_id).maybe(:int?)
  required(:active).maybe(:bool?)
end
