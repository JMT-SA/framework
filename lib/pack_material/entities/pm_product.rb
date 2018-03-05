# frozen_string_literal: true

module PackMaterialApp
  class PmProduct < Dry::Struct
    attribute :id, Types::Int
    attribute :material_resource_sub_type_id, Types::Int
    attribute :product_number, Types::Int
    attribute :description, Types::String
		attribute :active, Types::Bool

    attribute :commodity_id, Types::Int
    attribute :variety_id, Types::String

    attribute :style, Types::String
    attribute :assembly_type, Types::String
    attribute :market_major, Types::String
    attribute :ctn_size_basic_pack, Types::String
    attribute :ctn_size_old_pack, Types::String
    attribute :pls_pack_code, Types::String
    attribute :fruit_mass_nett_kg, Types::Decimal
    attribute :holes, Types::String
    attribute :perforation, Types::String
    attribute :image, Types::String
    attribute :length_mm, Types::Decimal
    attribute :width_mm, Types::Decimal
    attribute :height_mm, Types::Decimal
    attribute :diameter_mm, Types::Decimal
    attribute :thick_mm, Types::Decimal
    attribute :thick_mic, Types::Decimal
    attribute :colour, Types::String
    attribute :grade, Types::String
    attribute :mass, Types::String
    attribute :material_type, Types::String
    attribute :treatment, Types::String
    attribute :specification_notes, Types::String
    attribute :artwork_commodity, Types::String
    attribute :artwork_marketing_variety_group, Types::String
    attribute :artwork_variety, Types::String
    attribute :artwork_nett_mass, Types::String
    attribute :artwork_brand, Types::String
    attribute :artwork_class, Types::String
    attribute :artwork_plu_number, Types::Decimal
    attribute :artwork_other, Types::String
    attribute :artwork_image, Types::String
    attribute :marketer, Types::String
    attribute :retailer, Types::String
    attribute :supplier, Types::String
    attribute :supplier_stock_code, Types::String
    attribute :product_alternative, Types::String
    attribute :product_joint_use, Types::String
    attribute :ownership, Types::String
    attribute :consignment_stock, Types::Bool
    attribute :start_date, Types::Date
    attribute :end_date, Types::Date
    attribute :remarks, Types::String
  end
end
