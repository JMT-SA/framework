# frozen_string_literal: true

module MasterfilesApp
  SupplierTypeSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:type_code, Types::StrippedString).filled(:str?)
  end
end
