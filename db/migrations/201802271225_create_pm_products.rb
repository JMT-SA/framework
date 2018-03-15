# require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    create_table(:pack_material_products, ignore_index_errors: true) do
      primary_key :id
      foreign_key :material_resource_sub_type_id, :material_resource_sub_types, null: false, key: [:id]
      Integer :product_number, null: false
      String :description

      foreign_key :commodity_id, :commodities, key: [:id]
      # foreign_key :variety_id, :varieties, null: false, key: [:id]
      # String :commodity_id #Lookup
      String :variety_id #Lookup
      # String :variant
      String :style
      String :assembly_type
      String :market_major
      String :ctn_size_basic_pack #Lookup
      String :ctn_size_old_pack #Lookup
      String :pls_pack_code #Lookup
      Numeric :fruit_mass_nett_kg #NOTE: should we add a unit in here for LB or KG
      String :holes
      String :perforation
      String :image, text: true
      Numeric :length_mm
      Numeric :width_mm
      Numeric :height_mm
      Numeric :diameter_mm
      Numeric :thick_mm
      Numeric :thick_mic
      String :colour
      String :grade
      String :mass
      String :material_type
      String :treatment
      String :specification_notes, text: true
      String :artwork_commodity
      String :artwork_marketing_variety_group
      String :artwork_variety
      String :artwork_nett_mass
      String :artwork_brand
      String :artwork_class
      Numeric :artwork_plu_number
      String :artwork_other
      String :artwork_image, text: true
      String :marketer #Lookup
      String :retailer #Lookup
      String :supplier #Lookup #AlwaysActive
      String :supplier_stock_code #AlwaysActive
      String :product_alternative #Validate if the product code given here is a valid entry
      String :product_joint_use #Validate if the product code given here is a valid entry
      String :ownership
      TrueClass :consignment_stock, default: false
      Date :start_date #AlwaysActive
      Date :end_date #AlwaysActive
      TrueClass :active, default: true #AlwaysActive
      String :remarks, text: true #AlwaysActive

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:material_resource_sub_type_id], name: :fki_pack_material_products_material_resource_sub_types
    end
    pgt_created_at(:pack_material_products, :created_at, function_name: :pack_material_products_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:pack_material_products, :updated_at, function_name: :pack_material_products_set_updated_at, trigger_name: :set_updated_at)

    create_table(:pack_material_product_variants, ignore_index_errors: true) do
      primary_key :id
      foreign_key :pack_material_product_id, :pack_material_products, null: false, key: [:id]
      TrueClass :standard, default: false
      Integer :product_variant_number

      # Some of the fields from the products table needs to move/copy over to here
      # This one is placed here as an example
      String :colour

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:pack_material_product_id], name: :fki_pack_material_product_variants_pack_material_products
    end
    pgt_created_at(:pack_material_product_variants, :created_at, function_name: :pack_material_product_variants_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:pack_material_product_variants, :updated_at, function_name: :pack_material_product_variants_set_updated_at, trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:pack_material_product_variants, :set_created_at)
    drop_function(:pack_material_product_variants_set_created_at)
    drop_trigger(:pack_material_product_variants, :set_updated_at)
    drop_function(:pack_material_product_variants_set_updated_at)
    drop_table(:pack_material_product_variants)

    drop_trigger(:pack_material_products, :set_created_at)
    drop_function(:pack_material_products_set_created_at)
    drop_trigger(:pack_material_products, :set_updated_at)
    drop_function(:pack_material_products_set_updated_at)
    drop_table(:pack_material_products)
  end
end
