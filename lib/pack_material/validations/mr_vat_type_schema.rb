# frozen_string_literal: true

module PackMaterialApp
  MrVatTypeSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:vat_type_code, Types::StrippedString).maybe(:str?)
    required(:percentage_applicable, :decimal).maybe(:decimal?)
    required(:vat_not_applicable, :bool).maybe(:bool?)
  end
end
