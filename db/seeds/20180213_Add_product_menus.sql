-- NEW
INSERT INTO functional_areas (functional_area_name) VALUES ('Pack Material');

INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Config', 1, (SELECT id FROM functional_areas WHERE functional_area_name = 'Pack Material'));

INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs WHERE program_name = 'Config' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Pack Material')), 'Framework');

-- LIST menu item
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Config'
AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
'Types', '/list/material_resource_types', 2);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Config'
AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
'Sub Types', '/list/material_resource_sub_types', 2);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Config'
AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
'Product Codes', '/list/pack_material_products', 2);
--
-- INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
-- VALUES ((SELECT id FROM programs WHERE program_name = 'Config'
-- AND functional_area_id = (SELECT id FROM functional_areas
-- WHERE functional_area_name = 'Pack Material')),
-- 'Variant Product Codes', '/list/pack_material_products', 2);
--
-- INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
-- VALUES ((SELECT id FROM programs WHERE program_name = 'Config'
-- AND functional_area_id = (SELECT id FROM functional_areas
-- WHERE functional_area_name = 'Pack Material')),
-- 'Composite Products', '/list/pack_material_products', 2);

------------------------------------------------------------------------------

--
-- INSERT INTO functional_areas (functional_area_name) VALUES ('settings');
--
-- INSERT INTO programs (program_name, program_sequence, functional_area_id)
-- VALUES ('Pack material products', 1, (SELECT id FROM functional_areas WHERE functional_area_name = 'settings'));
--
-- INSERT INTO programs_webapps (program_id, webapp)
-- VALUES ((SELECT id FROM programs WHERE program_name = 'Pack material products' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'settings')), 'Framework');
--
-- INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
-- VALUES ((SELECT id FROM programs WHERE program_name = 'Pack material products'
-- AND functional_area_id = (SELECT id FROM functional_areas
-- WHERE functional_area_name = 'settings')),
-- 'MR types', '/list/material_resource_types', 2);
--
-- -- LIST menu item
-- INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
-- VALUES ((SELECT id FROM programs WHERE program_name = 'Pack material products'
-- AND functional_area_id = (SELECT id FROM functional_areas
-- WHERE functional_area_name = 'settings')),
-- 'MR sub types', '/list/material_resource_sub_types', 2);

-- This is created in the backend per domain - NO CRUD AVAILABLE for users
INSERT INTO material_resource_domains (domain_name, product_table_name, variant_table_name)
VALUES ('Pack Material', 'pack_material_products', 'pack_material_product_variants');

-- Make seed for all the product columns for this domain - ALSO NO CRUD
--  column_name, material_resource_domain_id, group_name, is_variant_column
INSERT INTO material_resource_product_columns (material_resource_domain_id, group_name, column_name, is_variant_column)
SELECT dom.id, sub.group_name, sub.column_name, sub.is_variant_column
FROM material_resource_domains dom
JOIN (SELECT * FROM (VALUES ('classification', 'variant', FALSE, 1),
  ('classification', 'style', FALSE, 1),
  ('classification', 'assembly_type', FALSE, 1),
  ('classification', 'market_major', FALSE, 1),
  ('classification', 'commodity', FALSE, 1),
  ('classification', 'variety', FALSE, 1),
  ('classification', 'ctn_size_basic_pack', FALSE, 1),
  ('classification', 'ctn_size_old_pack', FALSE, 1),
  ('classification', 'pls_pack_code', FALSE, 1),
  ('classification', 'fruit_mass_nett_kg', FALSE, 1),
  ('classification', 'holes', FALSE, 1),
  ('classification', 'perforation', FALSE, 1),
  ('classification', 'image', FALSE, 1),
  ('dimensions', 'length_mm', FALSE, 1),
  ('dimensions', 'width_mm', FALSE, 1),
  ('dimensions', 'height_mm', FALSE, 1),
  ('dimensions', 'diameter_mm', FALSE, 1),
  ('dimensions', 'thick_mm', FALSE, 1),
  ('dimensions', 'thick_mic', FALSE, 1),
  ('materials', 'colour', FALSE, 1),
  ('materials', 'grade', FALSE, 1),
  ('materials', 'mass', FALSE, 1),
  ('materials', 'material_type', FALSE, 1),
  ('materials', 'treatment', FALSE, 1),
  ('materials', 'specification_notes', FALSE, 1),
  ('artwork', 'artwork_commodity', FALSE, 1),
  ('artwork', 'artwork_marketing_variety_group', FALSE, 1),
  ('artwork', 'artwork_variety', FALSE, 1),
  ('artwork', 'artwork_nett_mass', FALSE, 1),
  ('artwork', 'artwork_brand', FALSE, 1),
  ('artwork', 'artwork_class', FALSE, 1),
  ('artwork', 'artwork_plu_number', FALSE, 1),
  ('artwork', 'artwork_other', FALSE, 1),
  ('artwork', 'artwork_image', FALSE, 1),
  ('organizations', 'marketer', FALSE, 1),
  ('organizations', 'retailer', FALSE, 1),
  ('organizations', 'supplier', FALSE, 1),
  ('organizations', 'supplier_stock_code', FALSE, 1),
  ('inventory_management', 'product_alternative', FALSE, 1),
  ('inventory_management', 'product_joint_use', FALSE, 1),
  ('inventory_management', 'ownership', FALSE, 1),
  ('inventory_management', 'consignment_stock', FALSE, 1),
  ('inventory_management', 'start_date', FALSE, 1),
  ('inventory_management', 'end_date', FALSE, 1),
  ('inventory_management', 'active', FALSE, 1),
  ('inventory_management', 'remarks', FALSE, 1))
    AS t(group_name, column_name, is_variant_column, n)) sub ON sub.n = 1
WHERE dom.domain_name = 'Pack Material';


-- retail_unit: %w(bag_fruit punnet tray protective bag_liner),
-- trade_unit: %w(carton bin lug),
-- logistics_unit: %w(pallet_base pallet_material),
-- label: %w(sticker fruit card ribbon),
-- other: %w(glue promotion sealing),
INSERT INTO material_resource_types (type_name, material_resource_domain_id)
VALUES ('Retail Unit', (SELECT material_resource_domains.id AS id FROM material_resource_domains WHERE material_resource_domains.domain_name = 'Pack Material'));

INSERT INTO material_resource_types (type_name, material_resource_domain_id)
VALUES ('Trade Unit', (SELECT material_resource_domains.id AS id FROM material_resource_domains WHERE material_resource_domains.domain_name = 'Pack Material'));

INSERT INTO material_resource_types (type_name, material_resource_domain_id)
VALUES ('Logistics Unit', (SELECT material_resource_domains.id AS id FROM material_resource_domains WHERE material_resource_domains.domain_name = 'Pack Material'));

INSERT INTO material_resource_types (type_name, material_resource_domain_id)
VALUES ('Label', (SELECT material_resource_domains.id AS id FROM material_resource_domains WHERE material_resource_domains.domain_name = 'Pack Material'));

INSERT INTO material_resource_types (type_name, material_resource_domain_id)
VALUES ('Other', (SELECT material_resource_domains.id AS id FROM material_resource_domains WHERE material_resource_domains.domain_name = 'Pack Material'));

INSERT INTO material_resource_sub_types (material_resource_type_id, sub_type_name)
  SELECT pt.id, sub.str
  FROM material_resource_types pt
    JOIN (SELECT * FROM (VALUES ('bag fruit', 1), ('punnet',1 ), ('tray', 1), ('protective', 1), ('bag liner', 1)) AS t(str, n)) sub ON sub.n = 1
  WHERE pt.type_name = 'Retail Unit';

INSERT INTO material_resource_sub_types (material_resource_type_id, sub_type_name)
  SELECT pt.id, sub.str
  FROM material_resource_types pt
    JOIN (SELECT * FROM (VALUES ('carton', 1), ('bin',1 ), ('lug', 1)) AS t(str, n)) sub ON sub.n = 1
  WHERE pt.type_name = 'Trade Unit';

INSERT INTO material_resource_sub_types (material_resource_type_id, sub_type_name)
  SELECT pt.id, sub.str
  FROM material_resource_types pt
    JOIN (SELECT * FROM (VALUES ('pallet base', 1), ('pallet material',1 )) AS t(str, n)) sub ON sub.n = 1
  WHERE pt.type_name = 'Logistics Unit';

INSERT INTO material_resource_sub_types (material_resource_type_id, sub_type_name)
  SELECT pt.id, sub.str
  FROM material_resource_types pt
    JOIN (SELECT * FROM (VALUES ('sticker', 1), ('fruit',1 ), ('card', 1), ('ribbon', 1)) AS t(str, n)) sub ON sub.n = 1
  WHERE pt.type_name = 'Label';

INSERT INTO material_resource_sub_types (material_resource_type_id, sub_type_name)
  SELECT pt.id, sub.str
  FROM material_resource_types pt
    JOIN (SELECT * FROM (VALUES ('glue', 1), ('promotion',1 ), ('sealing', 1)) AS t(str, n)) sub ON sub.n = 1
  WHERE pt.type_name = 'Other';

INSERT INTO material_resource_type_configs (material_resource_sub_type_id)
  select material_resource_sub_types.id from material_resource_sub_types;
