# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  module ConfigFactory
    def create_product(opts = {})
      sub_type = BaseRepo.new.find_hash(:material_resource_sub_types, @fixed_table_set[:matres_sub_types][:sc][:id])
      sub_id = sub_type[:id]
      type_id = sub_type[:material_resource_type_id]
      default = { material_resource_sub_type_id: sub_id,
                  unit: Faker::Lorem.unique.word,
                  brand_1: Faker::Lorem.unique.word,
                  style: Faker::Lorem.unique.word }
      prod_id = DB[:pack_material_products].insert(default.merge(opts))
      {
        id: prod_id,
        matres_type_id: type_id,
        matres_sub_type_id: sub_id
      }
    end

    def create_other_domain
      DB[:material_resource_domains].insert(
        domain_name: 'Other Domain',
        product_table_name: 'other_products',
        variant_table_name: 'other_product_variants'
      )
    end

    def create_matres_type(opts = {})
      default = {
        material_resource_domain_id: @fixed_table_set[:domain_id],
        type_name: Faker::Company.name.to_s,
        short_code: 'PZ',
        description: 'Material used to palletize'
      }
      DB[:material_resource_types].insert(default.merge(opts))
    end

    def create_sub_type(opts = {})
      sql = <<~SQL
        SELECT id FROM material_resource_product_columns
        WHERE column_name IN ('unit', 'style', 'brand_1', 'reference_size', 'reference_dimension', 'reference_quantity')
      SQL
      prod_col_ids = DB[sql].select_map
      prod_code_ids = prod_col_ids[0..2]
      default = {
        material_resource_type_id: @fixed_table_set[:matres_types][:sc][:id],
        sub_type_name: Faker::Company.name.to_s,
        short_code: Faker::Lorem.unique.word,
        active: true,
        product_code_ids: "{#{prod_code_ids.join(',')}}",
        product_column_ids: "{#{prod_col_ids.join(',')}}",
        product_variant_code_ids: '{1}'
      }
      DB[:material_resource_sub_types].insert(default.merge(opts))
    end

    def create_product_column(opts = {})
      dom_id = @fixed_table_set[:domain_id]
      default = {
        material_resource_domain_id: dom_id,
        column_name: Faker::Company.unique.name,
        short_code: Faker::Lorem.unique.word
      }
      DB[:material_resource_product_columns].insert(default.merge(opts))
    end

    def create_matres_master_list(opts = {})
      default = {
        material_resource_sub_type_id: @fixed_table_set[:matres_sub_types][:sc][:id],
        material_resource_product_column_id: @fixed_table_set[:matres_sub_types][:sc][:prod_code_ids].first
      }
      merged_attrs = default.merge(opts)
      list_id = DB[:material_resource_master_lists].insert(merged_attrs)
      merged_attrs.merge(id: list_id)
    end

    def create_matres_master_list_item(opts = {})
      list = create_matres_master_list
      default = {
        material_resource_master_list_id: list[:id],
        short_code: Faker::Lorem.unique.word,
        long_name: Faker::Lorem.word,
        description: Faker::Lorem.word
      }
      merged_attrs = default.merge(opts)
      item_id = DB[:material_resource_master_list_items].insert(merged_attrs)
      merged_attrs.merge(id: item_id)
    end
  end
end
# rubocop:enable Metrics/AbcSize
