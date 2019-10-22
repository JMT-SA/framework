# frozen_string_literal: true

module MasterfilesApp
  AccountCodeSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:account_code, :integer).filled(:int?)
    required(:description, Types::StrippedString).filled(:str?)
  end
end
