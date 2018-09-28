# frozen_string_literal: true

module MasterfilesApp
  OrganizationSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    # required(:party_id, :integer).filled(:int?)
    optional(:parent_id, :integer).maybe(:int?)
    required(:short_description, Types::StrippedString).filled(:str?)
    required(:medium_description, Types::StrippedString).maybe(:str?)
    required(:long_description, Types::StrippedString).maybe(:str?)
    required(:vat_number, Types::StrippedString).maybe(:str?)
    required(:role_ids, Types::IntArray).filled { each(:int?) }
    # required(:variants, Types::StrippedString).maybe(:str?)
    # required(:active, :bool).filled(:bool?)
  end
end
