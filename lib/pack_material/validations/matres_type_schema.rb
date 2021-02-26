# frozen_string_literal: true

module PackMaterialApp
  MatresTypeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:material_resource_domain_id).filled(:integer)
    required(:type_name).filled(:string)
    required(:short_code).filled(Types::StrippedString)
    required(:description).maybe(Types::StrippedString)
  end
end
