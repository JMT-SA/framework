# frozen_string_literal: true

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
      measurement_unit_ids.each do |unit_id|
        DB[:measurement_units_for_matres_types].insert(
          material_resource_type_id: id,
          measurement_unit_id: unit_id
        )
      end if measurement_unit_ids

      DB[:material_resource_types].where(id: id).update(params)
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
      products = all_hash(:"#{table_name}", material_resource_sub_type_id: id)
      if products.empty?
        delete(:material_resource_sub_types, id)
        success_response('ok')
      else
        associated_product_ids = products.map { |r| r[:id] }
        failed_response('There are products linked to this sub-type', associated_product_ids: associated_product_ids)
      end
    end

    def product_code_columns(id)
      query = <<~SQL
        SELECT pc.column_name, pc.id
        FROM unnest((SELECT st.product_code_ids FROM material_resource_sub_types st WHERE st.id = #{id})) product_code_id
        LEFT JOIN material_resource_product_columns pc on pc.id = product_code_id
      SQL
      DB[query].map { |rec| [rec[:column_name], rec[:id]] }
    end

    def product_code_column_subset(ids)
      for_select_material_resource_product_columns.select { |i| ids.include?(i[1]) }
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
  end
end
