# frozen_string_literal: true

module PackMaterialApp
  class ConfigRepo < RepoBase
    # TODO: possibly build alias into for_selects for shorter names
    build_for_select :material_resource_domains,
                     label: :domain_name,
                     value: :id,
                     no_active_check: true,
                     order_by: :domain_name
    build_for_select :material_resource_types,
                     label: :type_name,
                     value: :id,
                     no_active_check: true,
                     order_by: :type_name
    build_for_select :material_resource_sub_types,
                     label: :sub_type_name,
                     value: :id,
                     no_active_check: true,
                     order_by: :sub_type_name
    # TODO: custom for select based on product code
    # build_for_select :pack_material_products,
    #                  label: :product_code,
    #                  value: :id,
    #                  no_active_check: true,
    #                  order_by: :product_code

    crud_calls_for :material_resource_types, name: :matres_type, wrapper: MatresType
    crud_calls_for :material_resource_sub_types, name: :matres_sub_type, wrapper: MatresSubType
    crud_calls_for :pack_material_products, name: :pm_product, wrapper: PmProduct

    # TYPES
    def find_matres_type(id)
      hash = find_hash(:material_resource_types, id)
      domain = find_hash(:material_resource_domains, hash[:material_resource_domain_id])
      hash[:domain_name] = domain[:domain_name]
      return nil if hash.nil?
      MatresType.new(hash)
    end

    # SUB TYPES
    def create_matres_sub_type(args)
      sub_type_id = create(:material_resource_sub_types, args)
      create(:material_resource_type_configs, material_resource_sub_type_id: sub_type_id)
      sub_type_id
    end

    def delete_matres_sub_type(id)
      sub_type_hash = where_hash(:material_resource_sub_types, id: id)
      # Note: You can only delete a sub type if there are no products associated with it.
      type_hash = where_hash(:material_resource_types, id: sub_type_hash[:material_resource_type_id])
      domain_hash = where_hash(:material_resource_domains, id: type_hash[:material_resource_domain_id])

      products = where_hash(:"#{domain_hash[:product_table_name]}", material_resource_sub_type_id: sub_type_hash[:id])
      config_id = where_hash(:material_resource_type_configs, material_resource_sub_type_id: id)[:id]

      if products.nil?
        product_col_links = DB[:material_resource_product_columns_for_material_resource_types].where(material_resource_type_config_id: config_id)
        if product_col_links.any?
          product_col_link_ids = product_col_links.map { |r| r[:id] }
          # Delink product code columns
          product_code_col_links = DB[:material_resource_type_product_code_columns].where(material_resource_product_columns_for_material_resource_type_id: product_col_link_ids)
          product_code_col_links.delete
          # Delink product columns
          product_col_links.delete
        end
        # Delete config
        delete(:material_resource_type_configs, config_id)
        delete(:material_resource_sub_types, id)
        { success: true }
      else
        associated_product_ids = products.map{|r| r[:id] }
        { success: false, associated_product_ids: associated_product_ids }
      end
    end

    # CONFIGS
    # TODO: Consider making the Config One Entity as we are attempting to put all of it in one form anyway
    def find_matres_config(id)
      hash = find_hash(:material_resource_type_configs, id)
      hash = add_heritage(hash)
      return nil if hash.nil?
      MatresConfig.new(hash)
    end

    def find_matres_config_for_sub_type(sub_type_id)
      hash = where_hash(:material_resource_type_configs, material_resource_sub_type_id: sub_type_id)
      hash = add_heritage(hash)
      return nil if hash.nil?
      MatresConfig.new(hash)
    end

    def update_matres_config(id, attrs)
      update(:material_resource_type_configs, id, attrs)
    end

    def link_product_columns(config_id, col_ids)
      existing_ids      = type_product_column_ids(config_id)
      old_ids           = existing_ids - col_ids
      new_ids           = col_ids - existing_ids

      old_set = DB[:material_resource_product_columns_for_material_resource_types].where(material_resource_type_config_id: config_id).where(material_resource_product_column_id: old_ids)
      DB[:material_resource_type_product_code_columns].where(material_resource_product_columns_for_material_resource_type_id: old_set.map { |r| r[:id] }).delete
      old_set.delete
      new_ids.each do |prog_id|
        DB[:material_resource_product_columns_for_material_resource_types].insert(material_resource_type_config_id: config_id, material_resource_product_column_id: prog_id)
      end
    end

    def type_product_column_ids(config_id)
      DB[:material_resource_product_columns_for_material_resource_types].where(material_resource_type_config_id: config_id).select_map(:material_resource_product_column_id).sort
    end

    private

    def add_heritage(mr_type_hash)
      sub_type = find_hash(:material_resource_sub_types, mr_type_hash[:material_resource_sub_type_id])
      mr_type_hash[:sub_type_name] = sub_type[:sub_type_name]
      type = find_hash(:material_resource_types, sub_type[:material_resource_type_id])
      mr_type_hash[:type_name] = type[:type_name]
      domain = find_hash(:material_resource_domains, type[:material_resource_domain_id])
      mr_type_hash[:domain_name] = domain[:domain_name]
      mr_type_hash
    end

  end
end