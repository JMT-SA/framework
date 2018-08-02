# frozen_string_literal: true

module MasterfilesApp
  PartyRoleSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:party_id, :int).filled(:int?)
    required(:role_id, :int).filled(:int?)
    required(:organization_id, :int).maybe(:int?)
    required(:person_id, :int).maybe(:int?)
    required(:active, :bool).maybe(:bool?)
  end
end
