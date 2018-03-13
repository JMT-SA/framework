# frozen_string_literal: true

class PackMaterialRepo < RepoBase
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

  crud_calls_for :material_resource_types, name: :material_resource_type, wrapper: MaterialResourceType
  crud_calls_for :material_resource_sub_types, name: :material_resource_sub_type, wrapper: MaterialResourceSubType

  # build_for_select :material_resource_type_configs,
  #                  label: :product_code_separator,
  #                  value: :id,
  #                  order_by: :product_code_separator
  # build_inactive_select :material_resource_type_configs,
  #                       label: :product_code_separator,
  #                       value: :id,
  #                       order_by: :product_code_separator

  # build_for_select :material_resource_product_columns,
  #                  label: :column_name,
  #                  value: :id,
  #                  no_active_check: true,
  #                  order_by: :column_name

  # crud_calls_for :material_resource_type_configs, name: :material_resource_type_config, wrapper: MaterialResourceTypeConfig
  # crud_calls_for :material_resource_product_columns, name: :material_resource_product_column, wrapper: MaterialResourceProductColumn
  # crud_calls_for :material_resource_domains, name: :material_resource_domain, wrapper: MaterialResourceDomain

  def delete_material_resource_sub_type(id)
    sub_type_hash = where_hash(:material_resource_sub_types, id: id)
    # Are we going to say that you can only delete a sub type if there are no products associated with it.
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
    end
  end

  def find_material_resource_type_config(id)
    hash = find_hash(:material_resource_type_configs, id)
    hash = add_heritage(hash)
    hash = add_ids(hash)
    return nil if hash.nil?
    MaterialResourceTypeConfig.new(hash)
  end

  def add_heritage(mr_type_hash)
    sub_type = find_hash(:material_resource_sub_types, mr_type_hash[:material_resource_sub_type_id])
    mr_type_hash[:sub_type_name] = sub_type[:sub_type_name]
    type = find_hash(:material_resource_types, sub_type[:material_resource_type_id])
    mr_type_hash[:type_name] = type[:type_name]
    domain = find_hash(:material_resource_domains, type[:material_resource_domain_id])
    mr_type_hash[:domain_name] = domain[:domain_name]
    mr_type_hash
  end

  def add_ids(mr_type_config_hash)
    config_id = mr_type_config_hash[:id]
    mr_type_config_hash[:non_variant_product_code_column_ids] = non_variant_product_code_column_ids(config_id)
    mr_type_config_hash[:variant_product_code_column_ids] = variant_product_code_column_ids(config_id)
    mr_type_config_hash[:for_selected_non_variant_product_code_column_ids] = for_selected_non_variant_product_code_column_ids(config_id)
    mr_type_config_hash[:for_selected_variant_product_code_column_ids] = for_selected_variant_product_code_column_ids(config_id)
    p 'add_ids', mr_type_config_hash
    mr_type_config_hash
  end

  def find_material_resource_type_config_for_sub_type(sub_type_id)
    hash = where_hash(:material_resource_type_configs, material_resource_sub_type_id: sub_type_id)
    hash = add_heritage(hash)
    hash = add_ids(hash)
    return nil if hash.nil?
    MaterialResourceTypeConfig.new(hash)
  end

  def create_material_resource_sub_type(args)
    sub_type_id = create(:material_resource_sub_types, args)
    create(:material_resource_type_configs, material_resource_sub_type_id: sub_type_id)
    sub_type_id
  end

  def update_material_resource_type_config(id, attrs)
    update(:material_resource_type_configs, id, attrs)
  end

  # NOTE: Why does table material_resource_product_columns_for_material_resource_types have an id.
  def link_mr_product_columns(mr_type_config_id, mr_product_column_ids)
    # existing_ids      = mr_type_mr_product_column_ids(mr_type_config_id)
    # old_ids           = existing_ids - mr_product_column_ids
    # new_ids           = mr_product_column_ids - existing_ids
    #
    # old_set = DB[:material_resource_product_columns_for_material_resource_types].where(material_resource_type_config_id: mr_type_config_id).where(material_resource_product_column_id: old_ids)
    # DB[:material_resource_type_product_code_columns].where(material_resource_product_columns_for_material_resource_type_id: old_set.map{|r| r[:id]}).delete
    # old_set.delete
    # new_ids.each do |prog_id|
    #   DB[:material_resource_product_columns_for_material_resource_types].insert(material_resource_type_config_id: mr_type_config_id, material_resource_product_column_id: prog_id)
    # end
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

  def variant_product_code_column_ids(mr_type_config_id)
    # TODO: TEST
    ids = variant_product_column_ids(mr_type_config_id)
    set = product_code_columns_pure(mr_type_config_id).all.map{ |r| [r[:id], r[:product_column_id]] }
    id_set = []
    set.each do |i|
      id_set << i[1] if ids.include?(i[1])
    end
    id_set
  end

  def non_variant_product_code_column_ids(mr_type_config_id)
    ids = non_variant_product_column_ids(mr_type_config_id)
    set = product_code_columns_pure(mr_type_config_id).all.map{ |r| [r[:id], r[:product_column_id]] }
    id_set = []
    set.each do |i|
      id_set << i[1] if ids.include?(i[1])
    end
    id_set
  end

  def for_selected_variant_product_code_column_ids(mr_type_config_id)
    #note: this returns the product column ids
    ids = variant_product_column_ids(mr_type_config_id)
    product_code_columns_pure(mr_type_config_id).where(product_column_id: ids).map{|r| r[:product_column_id]}.sort
  end

  def for_selected_non_variant_product_code_column_ids(mr_type_config_id)
    #note: this returns the product column ids
    ids = non_variant_product_column_ids(mr_type_config_id)
    product_code_columns_pure(mr_type_config_id).where(product_column_id: ids).map{|r| r[:product_column_id]}.sort
  end

  def product_code_column_name_list(mr_type_config_id)
    set = product_code_columns(mr_type_config_id)
    set.map { |x| [x[:col] + ', ' + x[:group_name], x[:product_column_id]] }
  end

  def non_variant_product_code_column_name_list(config_id)
    set = product_code_columns(config_id)
    set.reject { |x| x[:is_variant] }.sort_by { |x| x[:pos] }
       .map { |x| [x[:col] + ', ' + x[:group_name], x[:product_column_id], "pos: #{x[:pos]}"] }
  end

  def variant_product_code_column_name_list(config_id)
    set = product_code_columns(config_id)
    set.select { |x| x[:is_variant] }.sort_by { |x| x[:pos] }
       .map { |x| [x[:col] + ', ' + x[:group_name], x[:product_column_id]] }
  end

  def product_code_columns(mr_type_config_id)
    product_code_columns_pure(mr_type_config_id).all
  end

  def product_code_columns_pure(mr_type_config_id)
    DB["SELECT mrtpcc.id as id, mrtpcc.position as pos, mrpc.column_name as col, mrpc.group_name as group_name,
          mrpc.id as product_column_id, mrpc.is_variant_column as is_variant
        FROM  material_resource_product_columns_for_material_resource_types mrpcfmrt,
              material_resource_type_product_code_columns mrtpcc,
              material_resource_product_columns mrpc
        WHERE mrtpcc.material_resource_product_columns_for_material_resource_type_id = mrpcfmrt.id
        AND mrpcfmrt.material_resource_type_config_id = #{mr_type_config_id}
        AND mrpc.id = mrpcfmrt.material_resource_product_column_id
        ORDER BY mrtpcc.position"]
  end

  def assign_non_variant_product_code_columns(config_id, col_ids)
    return { error: 'Choose at least one product code column' } if col_ids.empty?
    old_ids = non_variant_product_column_ids(config_id)
    old_link_ids = DB[:material_resource_product_columns_for_material_resource_types]
      .where(material_resource_product_column_id: old_ids, material_resource_type_config_id: config_id).map{|r| r[:id]}
    DB[:material_resource_type_product_code_columns].where(material_resource_product_columns_for_material_resource_type_id: old_link_ids).delete

    col_ids.each_with_index do |new_id, idx|
      link = DB[:material_resource_product_columns_for_material_resource_types]
        .where(material_resource_product_column_id: new_id, material_resource_type_config_id: config_id).first
      if link
        DB[:material_resource_type_product_code_columns].insert(material_resource_product_columns_for_material_resource_type_id: link[:id], position: idx)
      end
    end
    { success: true }
  end

  def assign_variant_product_code_columns(config_id, col_ids)
    return { error: 'Choose at least one variant product code column' } if col_ids.empty?
    old_ids = variant_product_column_ids(config_id)
    old_link_ids = DB[:material_resource_product_columns_for_material_resource_types]
                   .where(material_resource_product_column_id: old_ids, material_resource_type_config_id: config_id).map{ |r| r[:id] }
    DB[:material_resource_type_product_code_columns].where(material_resource_product_columns_for_material_resource_type_id: old_link_ids).delete

    col_ids.each_with_index do |new_id, idx|
      link = DB[:material_resource_product_columns_for_material_resource_types]
             .where(material_resource_product_column_id: new_id, material_resource_type_config_id: config_id).first
      if link
        buffer = non_variant_product_column_ids(config_id).count
        DB[:material_resource_type_product_code_columns].insert(material_resource_product_columns_for_material_resource_type_id: link[:id], position: (buffer + idx))
      end
    end
    { success: true }
  end

  def link_mr_product_code_columns(mr_type_config_id, mr_product_code_column_ids)
    allowed_ids       = mr_type_mr_product_column_ids(mr_type_config_id)
    new_set           = mr_product_code_column_ids & allowed_ids

    existing_ids      = mr_type_mr_product_code_column_ids(mr_type_config_id)
    old_ids           = existing_ids - new_set
    new_ids           = new_set - existing_ids

    # remove old
    old_link_ids = DB[:material_resource_product_columns_for_material_resource_types]
      .where(material_resource_product_column_id: old_ids, material_resource_type_config_id: mr_type_config_id).map{|r| r[:id]}
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
    product_column_ids = mr_product_code_column_ids.split(',')
    product_column_ids.each_with_index do |col_id, idx|
      link_id = DB[:material_resource_product_columns_for_material_resource_types]
                .where(material_resource_product_column_id: col_id,
                       material_resource_type_config_id: mr_type_config_id)
                .first[:id]
      DB[:material_resource_type_product_code_columns]
      .where(material_resource_product_columns_for_material_resource_type_id: link_id)
      .update(position: idx)
    end
  end

  def for_select_non_variant_product_code_column_ids(config_id)
    ids = non_variant_product_column_ids(config_id)
    DB[:material_resource_product_columns].where(id: ids).map{ |r| [r[:column_name], r[:id]] }
  end

  def for_select_variant_product_code_column_ids(config_id)
    ids = variant_product_column_ids(config_id)
    DB[:material_resource_product_columns].where(id: ids).map{ |r| [r[:column_name], r[:id]] }
  end

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
end


#
# # frozen_string_literal: true
#
# class ProductTypeRepo < RepoBase
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
#
#
#
#
#
#
#















