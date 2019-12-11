# frozen_string_literal: true

module Crossbeams
  module Config # rubocop:disable Metrics/ModuleLength
    MF_BASE_TABLES = %i[
      address_types
      basic_pack_codes
      business_processes
      commodity_groups
      contact_method_types
      cultivar_groups
      customer_types
      destination_regions
      fruit_size_references
      location_assignments
      location_storage_definitions
      location_storage_types
      location_types
      marketing_varieties
      master_lists
      material_resource_domains
      material_resource_types
      mr_cost_types
      mr_internal_batch_numbers
      mr_vat_types
      parties
      roles
      standard_pack_codes
      supplier_types
      target_market_group_types
      target_markets
      uom_types
      user_email_groups
      vehicle_types
    ].freeze

    # self-referential tables. First insert all where the key is NULL, then the rest.
    # This hash is in the form: table_name: self-referencing key
    MF_TABLES_SELF_REF = {}.freeze

    MF_TABLES_IN_SEQ = %i[
      addresses
      commodities
      contact_methods
      cultivars
      destination_countries
      destination_cities
      locations
      location_assignments_locations
      location_storage_types_locations
      tree_locations
      marketing_varieties_for_cultivars
      uoms
      std_fruit_size_counts
      target_market_groups
      target_markets_for_groups
      target_markets_for_countries
      organizations
      people
      party_roles
      party_addresses
      party_contact_methods
      fruit_actual_counts_for_packs
    ].freeze

    # For arrays of ids
    MF_LKP_ARRAY_RULES = {
      cultivar_ids: { subquery: 'SELECT array_agg(id) FROM cultivars WHERE cultivar_name IN ?', values: 'SELECT cultivar_name FROM cultivars WHERE id IN ?' }, # && commodity? :cultivar_id
      standard_pack_code_ids: { subquery: 'SELECT array_agg(id) FROM standard_pack_codes WHERE standard_pack_code IN ?', values: 'SELECT standard_pack_code FROM standard_pack_codes WHERE id IN ?' },
      size_reference_ids: { subquery: 'SELECT array_agg(id) FROM fruit_size_references WHERE size_reference IN ?', values: 'SELECT size_reference FROM fruit_size_references WHERE id IN ?' }
    }.freeze

    # The subquery is the subquery to be injected in the INSERT statement.
    # The values gets the key value to be used in the subquery for a particular row.
    MF_LKP_RULES = {
      address_id: { subquery: 'SELECT id FROM addresses WHERE address_type_id = (SELECT id FROM address_types where address_type = ?) AND address_line_1 = ? AND address_line_2 = ? AND city = ?', values: 'SELECT t.address_type, a.address_line_1, a.address_line_2, a.city FROM addresses a JOIN address_types t ON t.id = a.address_type_id WHERE a.id = ?' },
      address_type_id: { subquery: 'SELECT id FROM address_types WHERE address_type = ?', values: 'SELECT address_type FROM address_types WHERE id = ?' },
      contact_method_type_id: { subquery: 'SELECT id FROM contact_method_types WHERE contact_method_type = ?', values: 'SELECT contact_method_type FROM contact_method_types WHERE id = ?' },
      contact_method_id: { subquery: 'SELECT id FROM contact_methods WHERE contact_method_type_id = (SELECT id FROM contact_method_types WHERE contact_method_type = ?) AND contact_method_code = ?', values: 'SELECT t.contact_method_type, c.contact_method_code FROM contact_methods c JOIN contact_method_types t ON t.id = c.contact_method_type_id WHERE c.id = ?' },
      commodity_group_id: { subquery: 'SELECT id FROM commodity_groups WHERE code = ?', values: 'SELECT code FROM commodity_groups WHERE id = ?' },
      commodity_id: { subquery: 'SELECT id FROM commodities WHERE code = ?', values: 'SELECT code FROM commodities WHERE id = ?' },
      cultivar_group_id: { subquery: 'SELECT id FROM cultivar_groups WHERE cultivar_group_code = ?', values: 'SELECT cultivar_group_code FROM cultivar_groups WHERE id = ?' },
      cultivar_id: { subquery: 'SELECT id FROM cultivars WHERE cultivar_name = ?', values: 'SELECT cultivar_name FROM cultivars WHERE id = ?' }, # && commodity?
      pallet_base_id: { subquery: 'SELECT id FROM pallet_bases WHERE pallet_base_code = ?', values: 'SELECT pallet_base_code FROM pallet_bases WHERE id = ?' },
      pallet_stack_type_id: { subquery: 'SELECT id FROM pallet_stack_types WHERE stack_type_code = ?', values: 'SELECT stack_type_code FROM pallet_stack_types WHERE id = ?' },
      pallet_format_id: { subquery: 'SELECT id FROM pallet_formats WHERE pallet_base_id = (SELECT id FROM pallet_bases WHERE pallet_base_code = ?) AND pallet_stack_type_id = (SELECT id FROM pallet_stack_types WHERE stack_type_code = ?)', values: 'SELECT b.pallet_base_code, s.stack_type_code FROM pallet_formats f JOIN pallet_bases b ON b.id = f.pallet_base_id JOIN pallet_stack_types s ON s.id = f.pallet_stack_type_id WHERE f.id = ?' },
      basic_pack_id: { subquery: 'SELECT id FROM basic_pack_codes WHERE basic_pack_code = ?', values: 'SELECT basic_pack_code FROM basic_pack_codes WHERE id = ?' },
      basic_pack_code_id: { subquery: 'SELECT id FROM basic_pack_codes WHERE basic_pack_code = ?', values: 'SELECT basic_pack_code FROM basic_pack_codes WHERE id = ?' },
      destination_region_id: { subquery: 'SELECT id FROM destination_regions WHERE destination_region_name = ?', values: 'SELECT destination_region_name FROM destination_regions WHERE id = ?' },
      destination_country_id: { subquery: 'SELECT id FROM destination_countries WHERE country_name = ?', values: 'SELECT country_name FROM destination_countries WHERE id = ?' },
      primary_storage_type_id: { subquery: 'SELECT id FROM location_storage_types WHERE storage_type_code = ?', values: 'SELECT storage_type_code FROM location_storage_types WHERE id = ?' },
      location_storage_type_id: { subquery: 'SELECT id FROM location_storage_types WHERE storage_type_code = ?', values: 'SELECT storage_type_code FROM location_storage_types WHERE id = ?' },
      location_type_id: { subquery: 'SELECT id FROM location_types WHERE location_type_code = ?', values: 'SELECT location_type_code FROM location_types WHERE id = ?' },
      primary_assignment_id: { subquery: 'SELECT id FROM location_assignments WHERE assignment_code = ?', values: 'SELECT assignment_code FROM location_assignments WHERE id = ?' },
      location_assignment_id: { subquery: 'SELECT id FROM location_assignments WHERE assignment_code = ?', values: 'SELECT assignment_code FROM location_assignments WHERE id = ?' },
      location_storage_definition_id: { subquery: 'SELECT id FROM location_storage_definitions WHERE storage_definition_code = ?', values: 'SELECT storage_definition_code FROM location_storage_definitions WHERE id = ?' },
      location_id: { subquery: 'SELECT id FROM locations WHERE location_short_code = ?', values: 'SELECT location_short_code FROM locations WHERE id = ?' },
      ancestor_location_id: { subquery: 'SELECT id FROM locations WHERE location_short_code = ?', values: 'SELECT location_short_code FROM locations WHERE id = ?' },
      descendant_location_id: { subquery: 'SELECT id FROM locations WHERE location_short_code = ?', values: 'SELECT location_short_code FROM locations WHERE id = ?' },
      marketing_variety_id: { subquery: 'SELECT id FROM marketing_varieties WHERE marketing_variety_code = ?', values: 'SELECT marketing_variety_code FROM marketing_varieties WHERE id = ?' },
      plant_resource_type_id: { subquery: 'SELECT id FROM plant_resource_types WHERE plant_resource_type_code = ?', values: 'SELECT plant_resource_type_code FROM plant_resource_types WHERE id = ?' },
      system_resource_type_id: { subquery: 'SELECT id FROM system_resource_types WHERE system_resource_type_code = ?', values: 'SELECT system_resource_type_code FROM system_resource_types WHERE id = ?' },
      plant_resource_id: { subquery: 'SELECT id FROM plant_resources WHERE plant_resource_code = ?', values: 'SELECT plant_resource_code FROM plant_resources WHERE id = ?' },
      ancestor_plant_resource_id: { subquery: 'SELECT id FROM plant_resources WHERE plant_resource_code = ?', values: 'SELECT plant_resource_code FROM plant_resources WHERE id = ?' },
      descendant_plant_resource_id: { subquery: 'SELECT id FROM plant_resources WHERE plant_resource_code = ?', values: 'SELECT plant_resource_code FROM plant_resources WHERE id = ?' },
      system_resource_id: { subquery: 'SELECT id FROM system_resources WHERE system_resource_code = ?', values: 'SELECT system_resource_code FROM system_resources WHERE id = ?' },
      pm_type_id: { subquery: 'SELECT id FROM pm_types WHERE pm_type_code = ?', values: 'SELECT pm_type_code FROM pm_types WHERE id = ?' },
      pm_subtype_id: { subquery: 'SELECT id FROM pm_subtypes WHERE subtype_code = ?', values: 'SELECT subtype_code FROM pm_subtypes WHERE id = ?' },
      pm_product_id: { subquery: 'SELECT id FROM pm_products WHERE product_code = ?', values: 'SELECT product_code FROM pm_products WHERE id = ?' },
      pm_bom_id: { subquery: 'SELECT id FROM pm_boms WHERE bom_code = ?', values: 'SELECT bom_code FROM pm_boms WHERE id = ?' },
      uom_type_id: { subquery: 'SELECT id FROM uom_types WHERE code = ?', values: 'SELECT code FROM uom_types WHERE id = ?' },
      uom_id: { subquery: 'SELECT id FROM uoms WHERE uom_type_id = (SELECT id FROM uom_types WHERE code = ?) AND uom_code = ?', values: 'SELECT t.code, u.uom_code FROM uoms u JOIN uom_types t ON t.id = u.uom_type_id WHERE u.id = ?' },
      season_group_id: { subquery: 'SELECT id FROM season_groups WHERE season_group_code = ?', values: 'SELECT season_group_code FROM season_groups WHERE id = ?' },
      target_market_group_type_id: { subquery: 'SELECT id FROM target_market_group_types WHERE target_market_group_type_code = ?', values: 'SELECT target_market_group_type_code FROM target_market_group_types WHERE id = ?' },
      target_market_id: { subquery: 'SELECT id FROM target_markets WHERE target_market_name = ?', values: 'SELECT target_market_name FROM target_markets WHERE id = ?' },
      target_market_group_id: { subquery: 'SELECT id FROM target_market_groups WHERE target_market_group_name = ? AND target_market_group_type_id = (SELECT id FROM target_market_group_types WHERE target_market_group_type_code = ?)', values: 'SELECT g.target_market_group_name, t.target_market_group_type_code FROM target_market_groups g JOIN target_market_group_types t ON t.id = g.target_market_group_type_id WHERE g.id = ?' },
      treatment_type_id: { subquery: 'SELECT id FROM treatment_types WHERE treatment_type_code = ?', values: 'SELECT treatment_type_code FROM treatment_types WHERE id = ?' },
      customer_variety_id: { subquery: 'SELECT id FROM customer_varieties WHERE variety_as_customer_variety_id = (SELECT id FROM marketing_varieties WHERE marketing_variety_code = ?) AND packed_tm_group_id = (SELECT id FROM target_market_groups WHERE target_market_group_name = ? AND target_market_group_type_id = (SELECT id FROM target_market_group_types WHERE target_market_group_type_code = ?))', values: 'SELECT m.marketing_variety_code, g.target_market_group_name, t.target_market_group_type_code FROM customer_varieties c JOIN marketing_varieties m ON m.id = c.variety_as_customer_variety_id JOIN target_market_groups g ON g.id = c.packed_tm_group_id JOIN target_market_group_types t ON t.id = g.target_market_group_type_id WHERE c.id = ?' },
      variety_as_customer_variety_id: { subquery: 'SELECT id FROM marketing_varieties WHERE marketing_variety_code = ?', values: 'SELECT marketing_variety_code FROM marketing_varieties WHERE id = ?' },
      packed_tm_group_id: { subquery: 'SELECT id FROM target_market_groups WHERE target_market_group_name = ? AND target_market_group_type_id = (SELECT id FROM target_market_group_types WHERE target_market_group_type_code = ?)', values: 'SELECT g.target_market_group_name, t.target_market_group_type_code FROM target_market_groups g JOIN target_market_group_types t ON t.id = g.target_market_group_type_id WHERE g.id = ?' },
      puc_id: { subquery: 'SELECT id FROM pucs WHERE puc_code = ?', values: 'SELECT puc_code FROM pucs WHERE id = ?' },
      farm_id: { subquery: 'SELECT id FROM farms WHERE farm_code = ?', values: 'SELECT farm_code FROM farms WHERE id = ?' },
      farm_group_id: { subquery: 'SELECT id FROM farm_groups WHERE farm_group_code = ?', values: 'SELECT farm_group_code FROM farm_groups WHERE id = ?' },
      rmt_container_type_id: { subquery: 'SELECT id FROM rmt_container_types WHERE container_type_code = ?', values: 'SELECT container_type_code FROM rmt_container_types WHERE id = ?' },
      rmt_inner_container_type_id: { subquery: 'SELECT id FROM rmt_container_types WHERE container_type_code = ?', values: 'SELECT container_type_code FROM rmt_container_types WHERE id = ?' },
      std_fruit_size_count_id: { subquery: 'SELECT id FROM std_fruit_size_counts WHERE size_count_value = ? AND commodity_id = (SELECT id FROM commodities WHERE code = ?)', values: 'SELECT s.size_count_value, c.code FROM std_fruit_size_counts s JOIN commodities c ON c.id = s.commodity_id WHERE s.id = ?' },
      # standard_pack_code_ids, size_reference_ids, cultivar_ids
      role_id: { subquery: 'SELECT id FROM roles WHERE name = ?', values: 'SELECT name FROM roles WHERE id = ?' },
      organization_id: { subquery: 'SELECT id FROM organizations WHERE short_description = ?', values: 'SELECT short_description FROM organizations WHERE id = ?' },
      person_id: { subquery: 'SELECT id FROM people WHERE surname = ? AND first_name = ?', values: 'SELECT surname, first_name FROM people WHERE id = ?' },
      pdn_region_id: { subquery: 'SELECT id FROM production_regions WHERE production_region_code = ?', values: 'SELECT production_region_code FROM production_regions WHERE id = ?' },
      city_id: { subquery: 'SELECT id FROM destination_cities WHERE city_name = ?', values: 'SELECT city_name FROM destination_cities WHERE id = ?' },
      user_id: { subquery: 'SELECT id FROM users WHERE login_name = ?', values: 'SELECT login_name FROM users WHERE id = ?' },
      security_group_id: { subquery: 'SELECT id FROM security_groups WHERE security_group_name = ?', values: 'SELECT security_group_name FROM security_groups WHERE id = ?' },
      program_id: { subquery: 'SELECT id FROM programs WHERE program_name = ? AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = ?)', values: 'SELECT p.program_name, f.functional_area_name FROM programs p JOIN functional_areas f ON f.id = p.functional_area_id WHERE p.id = ?' },
      program_function_id: { subquery: 'SELECT id FROM program_functions WHERE program_function_name = ? AND program_id = (SELECT id FROM programs WHERE program_name = ? AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = ?))', values: 'SELECT pf.program_function_name, p.program_name, f.functional_area_name FROM program_functions pf JOIN programs p ON p.id = pf.program_id JOIN functional_areas f ON f.id = p.functional_area_id WHERE pf.id = ?' },
      start_page_program_function_id: { subquery: 'SELECT id FROM program_functions WHERE program_function_name = ? AND program_id = (SELECT id FROM programs WHERE program_name = ? AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = ?))', values: 'SELECT pf.program_function_name, p.program_name, f.functional_area_name FROM program_functions pf JOIN programs p ON p.id = pf.program_id JOIN functional_areas f ON f.id = p.functional_area_id WHERE pf.id = ?' },
      zzz: {}
    }.freeze

    MF_LKP_PARTY_ROLES = %i[
      owner_party_role_id
      rmt_material_owner_party_role_id
    ].freeze
  end
end
