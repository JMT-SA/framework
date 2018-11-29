# frozen_string_literal: true

module PackMaterialApp
  class PmProductVariant < Dry::Struct
    attribute :id, Types::Integer
    attribute :pack_material_product_id, Types::Integer
    attribute :product_variant_number, Types::String
    attribute :commodity_id, Types::Integer
    attribute :marketing_variety_id, Types::Integer
    attribute :unit, Types::String
    attribute :style, Types::String
    attribute :alternate, Types::String
    attribute :shape, Types::String
    attribute :reference_size, Types::String
    attribute :reference_dimension, Types::String
    attribute :reference_dimension_2, Types::String
    attribute :reference_quantity, Types::String
    attribute :brand_1, Types::String
    attribute :brand_2, Types::String
    attribute :colour, Types::String
    attribute :material, Types::String
    attribute :assembly, Types::String
    attribute :reference_mass, Types::String
    attribute :reference_number, Types::String
    attribute :market, Types::String
    attribute :marking, Types::String
    attribute :model, Types::String
    attribute :pm_class, Types::String
    attribute :grade, Types::String
    attribute :language, Types::String
    attribute :other, Types::String
    attribute :analysis_code, Types::String
    attribute :season_year_use, Types::String
    attribute :party, Types::String
    attribute :specification_reference, Types::String
  end
end
