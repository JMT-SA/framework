# frozen_string_literal: true

module MasterfilesApp
  OrganizationSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    # required(:party_id, :int).filled(:int?)
    optional(:parent_id, :int).maybe(:int?)
    required(:short_description, Types::StrippedString).filled(:str?)
    required(:medium_description, Types::StrippedString).maybe(:str?)
    required(:long_description, Types::StrippedString).maybe(:str?)
    required(:vat_number, Types::StrippedString).maybe(:str?)
    required(:role_ids, Types::IntArray).filled { each(:int?) }
    # required(:variants, Types::StrippedString).maybe(:str?)
    # required(:active, :bool).maybe(:bool?)
  end
end
