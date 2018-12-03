# frozen_string_literal: true

module MasterfilesApp
  UomTypeSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:code, Types::StrippedString).filled(:str?)
  end
end
