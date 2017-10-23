# frozen_string_literal: true

OrganizationSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  # required(:party_id).filled(:int?)
  optional(:parent_id).maybe(:int?)
  required(:short_description).filled(:str?)
  required(:medium_description).maybe(:str?)
  required(:long_description).maybe(:str?)
  required(:vat_number).maybe(:str?)
  optional(:role_id).maybe(:int?)
  # required(:variants).maybe(:str?)
  # required(:active).maybe(:bool?)
end
