require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:packing_material_product_types, ignore_index_errors: true) do
      primary_key :id
      String :packing_material_type_name, null: false
      index [:packing_material_type_name], name: :packing_material_product_types_unique_packing_material_type_name, unique: true
    end

    create_table(:packing_material_product_sub_types, ignore_index_errors: true) do
      primary_key :id
      foreign_key :packing_material_product_type_id, :packing_material_product_types, null: false, key: [:id]
      String :packing_material_sub_type_name, null: false
      index [:packing_material_sub_type_name], name: :packing_material_product_sub_types_unique_packing_material_sub_type_name, unique: true
      index [:packing_material_product_type_id], name: :fki_packing_material_product_sub_types_packing_material_product_types
    end

    create_table(:product_column_names, ignore_index_errors: true) do
      primary_key :id
      String :column_name, null: false
      String :group_name, null: false

      index [:column_name], name: :product_column_names_unique_column_name, unique: true
    end

    extension :pg_json
    create_table(:product_types, ignore_index_errors: true) do
      primary_key :id
      foreign_key :packing_material_product_type_id, :packing_material_product_types, null: false, key: [:id]
      foreign_key :packing_material_product_sub_type_id, :packing_material_product_sub_types, null: false, key: [:id]
      column :product_code_column_name_ordering, 'text[]'

      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    pgt_created_at(:product_types, :created_at, function_name: :product_types_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:product_types, :updated_at, function_name: :product_types_set_updated_at, trigger_name: :set_updated_at)

    create_table(:product_types_product_column_names, ignore_index_errors: true) do
      primary_key :id
      foreign_key :product_column_name_id, :product_column_names, null: false, key: [:id]
      foreign_key :product_type_id, :product_types, null: false, key: [:id]

      index [:product_column_name_id], name: :fki_product_types_product_column_names_product_column_names
      index [:product_type_id], name: :fki_product_types_product_column_names_product_types
    end

    create_table(:product_types_product_code_column_names, ignore_index_errors: true) do
      primary_key :id
      foreign_key :product_column_name_id, :product_column_names, null: false, key: [:id]
      foreign_key :product_type_id, :product_types, null: false, key: [:id]
      Integer :position, default: 0

      index [:product_column_name_id], name: :fki_product_types_product_code_column_names_product_column_names
      index [:product_type_id], name: :fki_product_types_product_code_column_names_product_types
    end

    create_table(:products, ignore_index_errors: true) do
      primary_key :id
      foreign_key :product_type_id, :product_types, null: false, key: [:id]

      String :variant
      String :style
      String :assembly_type
      String :market_major
      String :commodity #Lookup
      String :variety #Lookup
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

      index [:product_type_id], name: :fki_products_product_types
    end
    pgt_created_at(:products, :created_at, function_name: :products_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:products, :updated_at, function_name: :products_set_updated_at, trigger_name: :set_updated_at)

  end

  down do
    drop_trigger(:products, :set_created_at)
    drop_function(:products_set_created_at)
    drop_trigger(:products, :set_updated_at)
    drop_function(:products_set_updated_at)
    drop_table(:products)

    drop_table(:product_types_product_column_names)
    drop_table(:product_types_product_code_column_names)
    drop_table(:product_column_names)

    drop_trigger(:product_types, :set_created_at)
    drop_function(:product_types_set_created_at)
    drop_trigger(:product_types, :set_updated_at)
    drop_function(:product_types_set_updated_at)
    drop_table(:product_types)

    drop_table(:packing_material_product_sub_types)
    drop_table(:packing_material_product_types)
  end
end
