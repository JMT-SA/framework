Sequel.migration do
  up do
    table_names = %i[users functional_areas programs program_functions parties
                     roles organizations people party_roles address_types addresses contact_methods
                     party_contact_methods target_market_group_types target_market_groups target_markets
                     destination_regions destination_countries destination_cities commodity_groups
                     commodities vw_active_users material_resource_master_list_items pack_material_products
                     material_resource_sub_types pack_material_product_variants]

    table_names.each do |name|
      alter_table(name) do
        set_column_default :active, true
      end
    end
  end
end