# frozen_string_literal: true

class ProductTypeRepo < RepoBase
  # build_for_select :product_types,
  #                  label: :packing_material_product_type_id,
  #                  value: :id,
  #                  order_by: :packing_material_product_type_id
  # build_inactive_select :product_types,
  #                       label: :packing_material_product_type_id,
  #                       value: :id,
  #                       order_by: :packing_material_product_type_id

  # They will have to be custom because they have custom labels


  crud_calls_for :product_types, name: :product_type, wrapper: ProductType

  build_for_select :packing_material_product_types,
                   label: :packing_material_type_name,
                   value: :id,
                   no_active_check: true,
                   order_by: :packing_material_type_name

  crud_calls_for :packing_material_product_types, name: :packing_material_product_type, wrapper: PackingMaterialProductType

  build_for_select :packing_material_product_sub_types,
                   label: :packing_material_sub_type_name,
                   value: :id,
                   no_active_check: true,
                   order_by: :packing_material_sub_type_name

  crud_calls_for :packing_material_product_sub_types, name: :packing_material_product_sub_type, wrapper: PackingMaterialProductSubType

  build_for_select :products,
                   label: :variant,
                   value: :id,
                   order_by: :variant
  build_inactive_select :products,
                        label: :variant,
                        value: :id,
                        order_by: :variant

  crud_calls_for :products, name: :product, wrapper: Product

  def link_product_column_names(product_type_id, product_column_name_ids)
    existing_ids      = product_type_product_column_name_ids(product_type_id)
    old_ids           = existing_ids - product_column_name_ids
    new_ids           = product_column_name_ids - existing_ids

    DB[:product_types_product_column_names].where(product_type_id: product_type_id).where(product_column_name_id: old_ids).delete
    new_ids.each do |prog_id|
      DB[:product_types_product_column_names].insert(product_type_id: product_type_id, product_column_name_id: prog_id)
    end
  end

  def link_product_code_column_names(product_type_id, product_code_column_name_ids)
    allowed_ids       = product_type_product_column_name_ids(product_type_id)
    new_set           = product_code_column_name_ids & allowed_ids
    existing_ids      = product_type_product_code_column_name_ids(product_type_id)
    old_ids           = existing_ids - new_set
    new_ids           = new_set - existing_ids

    DB[:product_types_product_code_column_names].where(product_type_id: product_type_id).where(product_column_name_id: old_ids).delete
    new_ids.each do |prog_id|
      DB[:product_types_product_code_column_names].insert(product_type_id: product_type_id, product_column_name_id: prog_id)
    end
  end

  def product_type_product_column_name_ids(product_type_id)
    DB[:product_types_product_column_names].where(product_type_id: product_type_id).select_map(:product_column_name_id).sort
  end

  def product_type_product_code_column_name_ids(product_type_id)
    DB[:product_types_product_code_column_names].where(product_type_id: product_type_id).select_map(:product_column_name_id).sort
  end

  def product_code_column_name_list(product_type_id)
    column_names = DB[:product_types_product_code_column_names].join(:product_column_names, id: :product_column_name_id)
      .where(product_type_id: product_type_id).map { |r| [r[:column_name], r[:id]] }
    product = find_hash(:product_types, product_type_id)
    sorted_column_names = []
    order = product[:product_code_column_name_ordering]
    order.each do |ord|
      column_names.each do |x|
        sorted_column_names << x if x[1] == ord.to_i
      end
    end
    sorted_column_names
  end

  def store_product_code_column_ordering(id, column_codes_sorted_ids)
    update(:product_types, id, product_code_column_name_ordering: "{#{column_codes_sorted_ids}}")
  end

  private
  #
  # def add_party_name(hash)
  #   party_id = hash[:party_id]
  #   hash[:party_name] = DB['SELECT fn_party_name(?)', party_id].single_value
  #   hash
  # end
end






















