# frozen_string_literal: true

module MasterfilesApp
  CommodityGroupSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:code, Types::StrippedString).filled(:str?)
    required(:description, Types::StrippedString).filled(:str?)
    # required(:active, :bool).filled(:bool?)
  end
end
