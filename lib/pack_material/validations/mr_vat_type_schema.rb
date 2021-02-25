# frozen_string_literal: true

module PackMaterialApp
  MrVatTypeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:vat_type_code).maybe(Types::StrippedString)
    required(:percentage_applicable).maybe(:decimal)
    required(:vat_not_applicable).maybe(:bool)
  end
end
