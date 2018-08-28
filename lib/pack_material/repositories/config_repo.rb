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
                     alias: :units,
                     label: :unit_of_measure,
                     value: :id,
                     no_active_check: true,
                     order_by: :unit_of_measure

    crud_calls_for :material_resource_types, name: :matres_type, wrapper: MatresType
    crud_calls_for :material_resource_sub_types, name: :matres_sub_type, wrapper: MatresSubType
    crud_calls_for :pack_material_products, name: :pm_product, wrapper: PmProduct
    crud_calls_for :material_resource_master_list_items, name: :matres_master_list_item, wrapper: MatresMasterListItem
    crud_calls_for :material_resource_master_lists, name: :matres_master_list, wrapper: MatresMasterList

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
      measurement_unit_ids = params.delete(:measurement_units)

      # TODO: A helper method for the backend use of multi select ids for the simplest case?
      DB[:measurement_units_for_matres_types].where(material_resource_type_id: id).delete
      measurement_unit_ids&.each do |unit_id|
        DB[:measurement_units_for_matres_types].insert(
          material_resource_type_id: id,
          measurement_unit_id: unit_id
        )
      end

      DB[:material_resource_types].where(id: id).update(params) if params.any?
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
  end
end
# rubocop:enable Metrics/ClassLength
