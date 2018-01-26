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
    DB[:product_types_product_code_column_names].where(product_type_id: product_type_id).map { |r| [r[:column_name], r[:id]] }
  end

  private

  def add_party_name(hash)
    party_id = hash[:party_id]
    hash[:party_name] = DB['SELECT fn_party_name(?)', party_id].single_value
    hash
  end
end






















