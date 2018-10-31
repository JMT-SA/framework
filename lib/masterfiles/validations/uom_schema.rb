# frozen_string_literal: true

module MasterfilesApp
  UomSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:uoms_type_id, :integer).filled(:int?)
    required(:uom_code, Types::StrippedString).filled(:str?)
  end
end
