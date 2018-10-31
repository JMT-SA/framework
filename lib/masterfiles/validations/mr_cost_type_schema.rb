# frozen_string_literal: true

module MasterfilesApp
  MrCostTypeSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:cost_code_string, Types::StrippedString).maybe(:str?)
  end
end
