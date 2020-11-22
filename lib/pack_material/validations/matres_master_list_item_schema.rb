# frozen_string_literal: true

module PackMaterialApp
  MatresMasterListItemSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    optional(:material_resource_master_list_id).filled(:integer)
    optional(:material_resource_product_column_id).filled(:integer)
    optional(:short_code).filled(Types::StrippedString)
    required(:long_name).maybe(Types::StrippedString)
    required(:description).maybe(Types::StrippedString)
    optional(:active).maybe(:bool)
  end
end
