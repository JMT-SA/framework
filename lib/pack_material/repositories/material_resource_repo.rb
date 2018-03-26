# frozen_string_literal: true

module PackMaterialApp
  class MaterialResourceRepo < BaseRepo
    def link_mr_product_columns(mr_type_config_id, mr_product_column_ids)
      existing_ids      = mr_type_mr_product_column_ids(mr_type_config_id)
      old_ids           = existing_ids - mr_product_column_ids
      new_ids           = mr_product_column_ids - existing_ids

      old_set = DB[:material_resource_product_columns_for_material_resource_types].where(material_resource_type_config_id: mr_type_config_id).where(material_resource_product_column_id: old_ids)
      DB[:material_resource_type_product_code_columns].where(material_resource_product_columns_for_material_resource_type_id: old_set.map { |r| r[:id] }).delete
      old_set.delete
      new_ids.each do |prog_id|
        DB[:material_resource_product_columns_for_material_resource_types].insert(material_resource_type_config_id: mr_type_config_id, material_resource_product_column_id: prog_id)
      end
    end

    def mr_type_mr_product_column_ids(mr_type_config_id)
      DB[:material_resource_product_columns_for_material_resource_types].where(material_resource_type_config_id: mr_type_config_id).select_map(:material_resource_product_column_id).sort
    end

    def variant_product_column_ids(mr_type_config_id)
      product_column_ids = mr_type_mr_product_column_ids(mr_type_config_id)
      DB[:material_resource_product_columns].where(id: product_column_ids, is_variant_column: true).select_map(:id).sort
    end

    def non_variant_product_column_ids(mr_type_config_id)
      product_column_ids = mr_type_mr_product_column_ids(mr_type_config_id)
      DB[:material_resource_product_columns].where(id: product_column_ids, is_variant_column: false).select_map(:id).sort
    end

    def product_code_column_name_list(mr_type_config_id)
      set = product_code_columns(mr_type_config_id)
      set.map { |x| [x[:col] + ', ' + x[:group_name], x[:product_column_id]] }
    end

    def product_code_columns(mr_type_config_id)
      DB["SELECT mrtpcc.id as id, mrtpcc.position as pos, mrpc.column_name as col, mrpc.group_name as group_name, mrpc.id as product_column_id
		FROM  material_resource_product_columns_for_material_resource_types mrpcfmrt,
			    material_resource_type_product_code_columns mrtpcc,
			    material_resource_product_columns mrpc
		WHERE mrtpcc.material_resource_product_columns_for_material_resource_type_id = mrpcfmrt.id
		AND mrpcfmrt.material_resource_type_config_id = #{mr_type_config_id}
		AND mrpc.id = mrpcfmrt.material_resource_product_column_id
		ORDER BY mrtpcc.position"].all
    end

    def link_mr_product_code_columns(mr_type_config_id, mr_product_code_column_ids)
      allowed_ids       = mr_type_mr_product_column_ids(mr_type_config_id)
      new_set           = mr_product_code_column_ids & allowed_ids

      existing_ids      = mr_type_mr_product_code_column_ids(mr_type_config_id)
      old_ids           = existing_ids - new_set
      new_ids           = new_set - existing_ids

      # remove old
      old_link_ids = DB[:material_resource_product_columns_for_material_resource_types]
                     .where(material_resource_product_column_id: old_ids, material_resource_type_config_id: mr_type_config_id).map { |r| r[:id] }
      DB[:material_resource_type_product_code_columns].where(material_resource_product_columns_for_material_resource_type_id: old_link_ids).delete

      # add new - set position as last
      new_ids.each do |new_id|
        link = DB[:material_resource_product_columns_for_material_resource_types]
               .where(material_resource_product_column_id: new_id, material_resource_type_config_id: mr_type_config_id).first
        if link
          next_pos = next_product_code_column_position(mr_type_config_id)
          DB[:material_resource_type_product_code_columns].insert(material_resource_product_columns_for_material_resource_type_id: link[:id], position: next_pos)
        end
      end
    end

    def mr_type_mr_product_code_column_ids(mr_type_config_id)
      product_code_columns(mr_type_config_id).map { |r| r[:product_column_id] }.sort
    end

    def next_product_code_column_position(mr_type_config_id)
      set = product_code_columns(mr_type_config_id)
      set.any? ? set.map { |r| r[:position].to_i }.sort.last&.next : 0
    end

    def reorder_product_code_columns(mr_type_config_id, mr_product_code_column_ids)
      # TODO: TEST THE REORDERING
      product_column_ids = mr_product_code_column_ids.split(',')
      link_ids = DB[:material_resource_product_columns_for_material_resource_types]
                 .where(material_resource_product_column_id: product_column_ids,
                        material_resource_type_config_id: mr_type_config_id)
                 .map { |r| r[:id] }

      set = DB[:material_resource_type_product_code_columns].where(material_resource_product_columns_for_material_resource_type_id: link_ids)
      product_column_ids.each_with_index do |i, col_id|
        p 'col_id', col_id
        p 'idx', i
        set.where(id: col_id).update(position: i)
      end
    end
  end
end
