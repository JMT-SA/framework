# frozen_string_literal: true

module PackMaterialApp
  class PmProductRepo < BaseRepo
    build_for_select :pack_material_products,
                     label: :description,
                     value: :id,
                     order_by: :description
    build_inactive_select :pack_material_products,
                          label: :description,
                          value: :id,
                          order_by: :description

    crud_calls_for :pack_material_products, name: :pm_product, wrapper: PmProduct
  end
end

# DATAMINER QUERY IN REPO - maybe build this into base
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
