# frozen_string_literal: true

module PackMaterialApp
  MatresSubTypeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:material_resource_type_id).filled(:integer)
    optional(:inventory_uom_id).filled(:integer)
    required(:sub_type_name).filled(:string)
    required(:short_code).filled(Types::StrippedString)
    optional(:product_code_separator).filled(:string)
    optional(:has_suppliers).filled(:bool)
    optional(:has_marketers).filled(:bool)
    optional(:has_retailers).filled(:bool)
  end

  class MatresSubTypeConfigColumnsContract < Dry::Validation::Contract
    params do
      required(:chosen_column_ids).value(Types::IntArrayFromString)
      required(:columncodes_sorted_ids).filled(Types::IntArrayFromString)
      required(:variant_product_code_column_ids).filled(:array)
    end

    rule(:chosen_column_ids) do
      key.failure('is missing') if values[:chosen_column_ids] && values[:chosen_column_ids].empty?
    end

    rule(:columncodes_sorted_ids) do
      key.failure('is missing') if values[:chosen_column_ids] && values[:chosen_column_ids].empty?
    end
  end
end
