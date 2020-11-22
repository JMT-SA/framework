# frozen_string_literal: true

module PackMaterialApp
  MatresTypeSchema = Dry::Schema.Params do
    optional(:id).filled(:int?)
    required(:material_resource_domain_id).filled(:int?)
    required(:type_name).filled(:str?)
    required(:short_code).filled(Types::StrippedString)
    required(:description).maybe(Types::StrippedString)
  end
end
