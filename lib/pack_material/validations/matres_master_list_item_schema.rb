# frozen_string_literal: true

module PackMaterialApp
  MatresMasterListItemSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    optional(:material_resource_master_list_id, :int).filled(:int?)
    optional(:material_resource_product_column_id, :int).filled(:int?)
    optional(:short_code, Types::StrippedString).filled(:str?)
    required(:long_name, Types::StrippedString).maybe(:str?)
    required(:description, Types::StrippedString).maybe(:str?)
    optional(:active, :bool).filled(:bool?)
  end
end
