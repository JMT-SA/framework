# frozen_string_literal: true

module MasterfilesApp
  PartyRoleSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:party_id, :integer).filled(:int?)
    required(:role_id, :integer).filled(:int?)
    required(:organization_id, :integer).maybe(:int?)
    required(:person_id, :integer).maybe(:int?)
    required(:active, :bool).filled(:bool?)
  end
end
