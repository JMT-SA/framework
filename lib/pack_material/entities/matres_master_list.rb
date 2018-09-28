# frozen_string_literal: true

module PackMaterialApp
  class MatresMasterList < Dry::Struct
    attribute :id, Types::Integer
    attribute :material_resource_sub_type_id, Types::Integer
    attribute :material_resource_product_column_id, Types::Integer
  end
end
