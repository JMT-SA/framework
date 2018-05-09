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

#
# def product_column_options(product_id)
#   options = {}
#   product_type_id = DB[:products].where(id: product_id).select(:product_type_id).single_value
#   product_column_ids = DB[:product_types_product_column_names].where(product_type_id: product_type_id).select_map(:product_column_name_id)
#   product_columns = DB[:product_column_names].where(id: product_column_ids).select_map{|x| [x.group_name, x.column_name] }
#   product_columns.each do |col|
#     options[:"#{col[0]}"] = {} unless options[:"#{col[0]}"]
#     options[:"#{col[0]}"][:"#{col[1]}"] = true
#   end
#   options
# end

# def find_product(id)
#   hash = find_hash(:products, id)
#   hash[:product_type_name] = find_product_type_name(hash[:product_type_id])
#   return nil if hash.nil?
#   Product.new(hash)
# end
#
# def find_product_type(id)
#   hash = find_hash(:product_types, id)
#   hash = add_product_type_name(hash)
#   return nil if hash.nil?
#   ProductType.new(hash)
# end
#
# def for_select_product_types
#   for_select = []
#   dataset_ids = DB[:product_types].all.map{|x| x[:id]}
#   dataset_ids.each do |id|
#     for_select << [DB['SELECT fn_product_type_name(?)', id].single_value, id]
#   end
#   for_select
# end

#
# private
#
# def add_product_type_name(hash)
#   hash[:name] = DB['SELECT fn_product_type_name(?)', hash[:id]].single_value
#   hash
# end
#
# def find_product_type_name(product_type_id)
#   DB['SELECT fn_product_type_name(?)', product_type_id].single_value
# end
#
#
#
#

# def get_dataminer_query(file_name)
#   DB[get_dataminer_report(file_name).sql].all
# end
#
# def get_dataminer_report(file_name)
#   # Load a YML report.
#   path     = File.join(ENV['ROOT'], 'grid_definitions', 'dataminer_queries', file_name.sub('.yml', '') << '.yml')
#   rpt_hash = Crossbeams::Dataminer::YamlPersistor.new(path)
#   Crossbeams::Dataminer::Report.load(rpt_hash)
# end

# # frozen_string_literal: true
#
# class ProductTypeRepo < BaseRepo
#   # build_for_select :product_types,
#   #                  label: :packing_material_product_type_id,
#   #                  value: :id,
#   #                  order_by: :packing_material_product_type_id
#   # build_inactive_select :product_types,
#   #                       label: :packing_material_product_type_id,
#   #                       value: :id,
#   #                       order_by: :packing_material_product_type_id
#
#   # They will have to be custom because they have custom labels
#
#
#   crud_calls_for :product_types, name: :product_type, wrapper: ProductType
#
#   build_for_select :packing_material_product_types,
#                    label: :packing_material_type_name,
#                    value: :id,
#                    no_active_check: true,
#                    order_by: :packing_material_type_name
#
#   crud_calls_for :packing_material_product_types, name: :packing_material_product_type, wrapper: PackingMaterialProductType
#
#   build_for_select :packing_material_product_sub_types,
#                    label: :packing_material_sub_type_name,
#                    value: :id,
#                    no_active_check: true,
#                    order_by: :packing_material_sub_type_name
#
#   crud_calls_for :packing_material_product_sub_types, name: :packing_material_product_sub_type, wrapper: PackingMaterialProductSubType
#
#   build_for_select :products,
#                    label: :variant,
#                    value: :id,
#                    order_by: :variant
#   build_inactive_select :products,
#                         label: :variant,
#                         value: :id,
#                         order_by: :variant
#
#   crud_calls_for :products, name: :product, wrapper: Product
#
#   def link_product_column_names(product_type_id, product_column_name_ids)
#     existing_ids      = product_type_product_column_name_ids(product_type_id)
#     old_ids           = existing_ids - product_column_name_ids
#     new_ids           = product_column_name_ids - existing_ids
#
#     DB[:product_types_product_column_names].where(product_type_id: product_type_id).where(product_column_name_id: old_ids).delete
#     new_ids.each do |prog_id|
#       DB[:product_types_product_column_names].insert(product_type_id: product_type_id, product_column_name_id: prog_id)
#     end
#   end
#
#   def link_product_code_column_names(product_type_id, product_code_column_name_ids)
#     allowed_ids       = product_type_product_column_name_ids(product_type_id)
#     new_set           = product_code_column_name_ids & allowed_ids
#     existing_ids      = product_type_product_code_column_name_ids(product_type_id)
#     old_ids           = existing_ids - new_set
#     new_ids           = new_set - existing_ids
#
#     DB[:product_types_product_code_column_names].where(product_type_id: product_type_id).where(product_column_name_id: old_ids).delete
#     new_ids.each do |prog_id|
#       DB[:product_types_product_code_column_names].insert(product_type_id: product_type_id, product_column_name_id: prog_id)
#     end
#   end
#
#   def product_type_product_column_name_ids(product_type_id)
#     DB[:product_types_product_column_names].where(product_type_id: product_type_id).select_map(:product_column_name_id).sort
#   end
#
#   def product_type_product_code_column_name_ids(product_type_id)
#     DB[:product_types_product_code_column_names].where(product_type_id: product_type_id).select_map(:product_column_name_id).sort
#   end
#
#   def product_code_column_name_list(product_type_id)
#     column_names = DB[:product_types_product_code_column_names].join(:product_column_names, id: :product_column_name_id)
#       .where(product_type_id: product_type_id).map { |r| [r[:column_name], r[:id]] }
#     product = find_hash(:product_types, product_type_id)
#     sorted_column_names = []
#     order = []
#     if product[:product_code_column_name_ordering]
#       order = product[:product_code_column_name_ordering]
#     else
#       column_names.each do |col|
#         order << col[1]
#       end
#     end
#     order.each do |ord|
#       column_names.each do |x|
#         sorted_column_names << x if x[1] == ord.to_i
#       end
#     end
#     p column_names
#
#     p sorted_column_names
#     sorted_column_names
#   end
#
#   def store_product_code_column_ordering(id, column_codes_sorted_ids)
#     update(:product_types, id, product_code_column_name_ordering: "{#{column_codes_sorted_ids}}")
#   end
#
#   def find_product(id)
#     hash = find_hash(:products, id)
#     hash[:product_type_name] = find_product_type_name(hash[:product_type_id])
#     return nil if hash.nil?
#     Product.new(hash)
#   end
#
#   def find_product_type(id)
#     hash = find_hash(:product_types, id)
#     hash = add_product_type_name(hash)
#     return nil if hash.nil?
#     ProductType.new(hash)
#   end
#
#   def for_select_product_types
#     for_select = []
#     dataset_ids = DB[:product_types].all.map{|x| x[:id]}
#     dataset_ids.each do |id|
#       for_select << [DB['SELECT fn_product_type_name(?)', id].single_value, id]
#     end
#     for_select
#   end
#
#   def product_column_options(product_id)
#     options = {}
#     product_type_id = DB[:products].where(id: product_id).select(:product_type_id).single_value
#     product_column_ids = DB[:product_types_product_column_names].where(product_type_id: product_type_id).select_map(:product_column_name_id)
#     product_columns = DB[:product_column_names].where(id: product_column_ids).select_map{|x| [x.group_name, x.column_name] }
#     product_columns.each do |col|
#       options[:"#{col[0]}"] = {} unless options[:"#{col[0]}"]
#       options[:"#{col[0]}"][:"#{col[1]}"] = true
#     end
#     options
#   end
#
#   private
#
#   def add_product_type_name(hash)
#     hash[:name] = DB['SELECT fn_product_type_name(?)', hash[:id]].single_value
#     hash
#   end
#
#   def find_product_type_name(product_type_id)
#     DB['SELECT fn_product_type_name(?)', product_type_id].single_value
#   end
# end
