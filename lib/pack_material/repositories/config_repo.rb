# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

module PackMaterialApp
  class ConfigRepo < BaseRepo
    build_for_select :material_resource_domains,
                     alias: 'domains',
                     label: :domain_name,
                     value: :id,
                     no_active_check: true,
                     order_by: :domain_name
    build_for_select :material_resource_types,
                     alias: 'matres_types',
                     label: :type_name,
                     value: :id,
                     no_active_check: true,
                     order_by: :type_name
    build_for_select :material_resource_sub_types,
                     alias: 'matres_sub_types',
                     label: :sub_type_name,
                     value: :id,
                     no_active_check: true,
                     order_by: :sub_type_name

    build_for_select :material_resource_product_columns,
                     label: :column_name,
                     value: :id,
                     no_active_check: true,
                     order_by: :column_name
    build_for_select :measurement_units,
                     alias: 'units',
                     label: :unit_of_measure,
                     value: :id,
                     no_active_check: true,
                     order_by: :unit_of_measure
    build_for_select :material_resource_product_variants,
                     alias: 'matres_product_variants',
                     label: :product_variant_table_name,
                     value: :id,
                     no_active_check: true,
                     order_by: :product_variant_table_name
    build_for_select :material_resource_product_variant_party_roles,
                     alias: 'matres_product_variant_party_roles',
                     label: :party_stock_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :party_stock_code

    crud_calls_for :material_resource_types, name: :matres_type, wrapper: MatresType
    crud_calls_for :material_resource_sub_types, name: :matres_sub_type, wrapper: MatresSubType
    crud_calls_for :pack_material_products, name: :pm_product, wrapper: PmProduct
    crud_calls_for :material_resource_master_list_items, name: :matres_master_list_item, wrapper: MatresMasterListItem
    crud_calls_for :material_resource_master_lists, name: :matres_master_list, wrapper: MatresMasterList
    crud_calls_for :material_resource_product_variants, name: :matres_product_variant, wrapper: MatresProductVariant
    crud_calls_for :material_resource_product_variant_party_roles, name: :matres_product_variant_party_role, wrapper: MatresProductVariantPartyRole

    def create_matres_product_variant_party_role(attrs)
      hash = attrs.to_h
      message = nil
      message = 'Can not assign both customer and supplier' if hash[:supplier_id] && hash[:customer_id]
      message ||= 'Must have customer or supplier' if hash[:supplier_id].nil? && hash[:customer_id].nil?
      message ||= 'Supplier already exists' if hash[:supplier_id] && exists?(:material_resource_product_variant_party_roles, supplier_id: hash[:supplier_id])
      message ||= 'Customer already exists' if hash[:customer_id] && exists?(:material_resource_product_variant_party_roles, customer_id: hash[:customer_id])
      return validation_failed_response(OpenStruct.new(messages: message)) if message

      role_id = DB[:material_resource_product_variant_party_roles].insert(hash.to_h)
      success_response('ok', role_id)
    end

    def find_full_party_role(id)
      hash = DB[:material_resource_product_variant_party_roles].where(id: id).first
      supplier_id = hash[:supplier_id]
      hash[:role_type] = supplier_id ? 'supplier' : 'customer'
      party = supplier_id ? find_hash(:suppliers, supplier_id) : find_hash(:customers, hash[:customer_id])
      hash.merge!(DB["SELECT fn_party_role_name(#{party[:party_role_id]}) as party_name"].first)
      FullMatresProductVariantPartyRole.new(hash)
    end

    def domain_id
      DB[:material_resource_domains].where(domain_name: DOMAIN_NAME).first[:id]
    end

    def for_select_configured_sub_types(domain_name)
      optgroup_array(DB["SELECT mrst.sub_type_name, mrst.id, mrt.short_code as type_name from material_resource_sub_types mrst
      LEFT JOIN material_resource_types mrt on mrst.material_resource_type_id = mrt.id
      LEFT JOIN material_resource_domains dom on mrt.material_resource_domain_id = dom.id
      WHERE dom.domain_name = '#{domain_name}' AND mrst.active IS true AND mrst.product_code_ids IS NOT null;"].all, :type_name, :sub_type_name, :id)
    end

    # TYPES
    def find_matres_type(id)
      hash = find_hash(:material_resource_types, id)
      return nil if hash.nil?
      domain = find_hash(:material_resource_domains, hash[:material_resource_domain_id])
      hash[:domain_name] = domain ? domain[:domain_name] : 'unknown domain name'
      MatresType.new(hash)
    end

    def update_matres_type(id, attrs)
      params = attrs.to_h
      measurement_unit_ids = params.delete(:measurement_units) || []

      # TODO: A helper method for the backend use of multi select ids for the simplest case?
      units_added = nil
      DB[:measurement_units_for_matres_types].where(material_resource_type_id: id).delete
      measurement_unit_ids&.each do |unit_id|
        DB[:measurement_units_for_matres_types].insert(
          material_resource_type_id: id,
          measurement_unit_id: unit_id
        )
      end
      units_added = 'measurement units were added' if measurement_unit_ids.any?

      short_code_notice = nil
      if matres_type_has_products(id)
        params.delete(:short_code)
        short_code_notice = 'Short code can not be updated if products are present'
      end
      update(:material_resource_types, id, params) if params.any?
      success_response([units_added, short_code_notice].compact.join(', '))
    end

    def measurement_units
      DB[:measurement_units].select_map(:unit_of_measure)
    end

    def matres_type_measurement_units(matres_type_id)
      DB[:measurement_units].where(id: DB[:measurement_units_for_matres_types]
                                         .where(material_resource_type_id: matres_type_id)
                                         .select_map(:measurement_unit_id))
                            .select_map(:unit_of_measure)
    end

    def matres_type_measurement_unit_ids(matres_type_id)
      DB[:measurement_units].where(id: DB[:measurement_units_for_matres_types]
                                         .where(material_resource_type_id: matres_type_id)
                                         .select_map(:measurement_unit_id))
                            .select_map(:id)
    end

    def create_matres_type_unit(matres_type_id, unit_of_measure_string)
      unit_id = DB[:measurement_units].insert(unit_of_measure: unit_of_measure_string)
      if unit_id
        DB[:measurement_units_for_matres_types].insert(
          material_resource_type_id: matres_type_id,
          measurement_unit_id: unit_id
        )
      end
      unit_id
    end

    def add_matres_type_unit(matres_type_id, unit_of_measure_string)
      DB[:measurement_units_for_matres_types].insert(
        material_resource_type_id: matres_type_id,
        measurement_unit_id: DB[:measurement_units].where(unit_of_measure: unit_of_measure_string).select(:id)
      )
    end

    # SUB TYPES
    def update_matres_sub_type(id, attrs)
      short_code_notice = nil
      if matres_sub_type_has_products(id)
        attrs.delete(:short_code)
        short_code_notice = 'Short code can not be updated if products are present'
      end
      update(:material_resource_sub_types, id, attrs) if attrs.any?
      { success: true, message: short_code_notice }
    end

    def delete_matres_sub_type(id)
      query = <<~SQL
        SELECT product_table_name
        FROM material_resource_sub_types st
        JOIN material_resource_types t   ON t.id = st.material_resource_type_id
        JOIN material_resource_domains d ON d.id = t.material_resource_domain_id
        WHERE st.id = #{id}
      SQL
      table_name = DB[query].single_value
      product_ids = matres_sub_type_product_ids(id, table_name)
      if product_ids.any?
        failed_response('There are products linked to this sub-type', associated_product_ids: product_ids)
      else
        delete(:material_resource_sub_types, id)
        success_response('ok')
      end
    end

    def matres_sub_type_product_ids(id, table_name)
      all_hash(:"#{table_name}", material_resource_sub_type_id: id).map { |r| r[:id] }
    end

    def product_variant_columns(sub_type_id)
      sub_type = DB[:material_resource_sub_types].where(id: sub_type_id).first
      product_variant_column_ids = (sub_type[:product_column_ids] || []) - (sub_type[:product_code_ids] || [])
      DB[:material_resource_product_columns].where(id: product_variant_column_ids)
                                            .map { |rec| [rec[:column_name], rec[:id]] }
    end

    def product_code_columns(sub_type_id)
      query = <<~SQL
        SELECT pc.column_name, pc.id
        FROM unnest((SELECT st.product_code_ids FROM material_resource_sub_types st WHERE st.id = #{sub_type_id})) product_code_id
        LEFT JOIN material_resource_product_columns pc on pc.id = product_code_id
      SQL
      DB[query].map { |rec| [rec[:column_name], rec[:id]] }
    end

    def product_code_column_subset(ids)
      for_select_material_resource_product_columns.select { |i| ids.include?(i[1]) }
    end

    def product_columns(sub_type_id)
      sub_type = DB[:material_resource_sub_types].where(id: sub_type_id).first
      product_column_ids = (sub_type[:product_column_ids] || [])
      for_select_material_resource_product_columns.select { |i| product_column_ids.include?(i[1]) }
    end

    def update_product_code_configuration(config_id, res)
      changes = <<~SQL
        UPDATE material_resource_sub_types
           SET product_column_ids = '{#{res[:chosen_column_ids].join(',')}}',
               product_code_ids = '{#{res[:columncodes_sorted_ids].join(',')}}'
        WHERE id = #{config_id};
      SQL

      DB[changes].update
      success_response('ok')
    end

    def sub_type_master_list_items(sub_type_id)
      DB[get_dataminer_report('matres_prodcol_sub_type_list_items.yml').sql].where(sub_type_id: sub_type_id)
    end

    def for_select_sub_type_master_list_items(sub_type_id, product_column)
      sub_type_master_list_items(sub_type_id).map { |r| [(r[:short_code] + (r[:long_name] ? ' - ' + r[:long_name] : '')).to_s, r[:id]] if r[:column_name] == product_column.to_s && r[:active] }
        .compact
    end

    def get_dataminer_report(file_name)
      path = File.join(ENV['ROOT'], 'grid_definitions', 'dataminer_queries', file_name.sub('.yml', '') << '.yml')
      rpt_hash = Crossbeams::Dataminer::YamlPersistor.new(path)
      Crossbeams::Dataminer::Report.load(rpt_hash)
    end

    def create_matres_sub_type_master_list_item(sub_type_id, attrs)
      new_attrs = attrs.to_h
      prod_col_id = new_attrs.delete(:material_resource_product_column_id)
      existing_list = DB[:material_resource_master_lists].where(
        material_resource_sub_type_id: sub_type_id,
        material_resource_product_column_id: prod_col_id
      ).first
      list_id = existing_list ? existing_list[:id] : nil
      list_id ||= DB[:material_resource_master_lists].insert(
        material_resource_sub_type_id: sub_type_id,
        material_resource_product_column_id: prod_col_id
      )
      new_attrs[:material_resource_master_list_id] = list_id
      DB[:material_resource_master_list_items].insert(new_attrs)
    end

    def find_matres_product_column(id)
      find(:material_resource_product_columns, MatresProductColumn, id)
    end

    def matres_sub_type_master_list_items(sub_type_id, product_column_id)
      list = DB[:material_resource_master_lists].where(
        material_resource_sub_type_id: sub_type_id,
        material_resource_product_column_id: product_column_id
      ).first
      if list
        all(:material_resource_master_list_items, MatresMasterListItem, material_resource_master_list_id: list[:id])
      else
        []
      end
    end

    def matres_sub_type_has_products(sub_type_id)
      exists?(:pack_material_products, material_resource_sub_type_id: sub_type_id)
    end

    def matres_type_has_products(type_id)
      sub_type_ids = DB[:material_resource_sub_types].where(material_resource_type_id: type_id).select_map(:id)
      exists?(:pack_material_products, material_resource_sub_type_id: sub_type_ids)
    end

    def link_alternatives(variant_id, alternative_ids)
      DB[:alternative_material_resource_product_variants].where(material_resource_product_variant_id: variant_id).delete
      alternative_ids.each do |prog_id|
        DB[:alternative_material_resource_product_variants].insert(material_resource_product_variant_id: variant_id, alternative_id: prog_id)
      end
    end

    def link_co_use_product_codes(variant_id, co_use_ids)
      DB[:co_use_material_resource_product_variants].where(material_resource_product_variant_id: variant_id).delete
      co_use_ids.each do |prog_id|
        DB[:co_use_material_resource_product_variants].insert(material_resource_product_variant_id: variant_id, co_use_id: prog_id)
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
