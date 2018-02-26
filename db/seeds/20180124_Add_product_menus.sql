INSERT INTO functional_areas (functional_area_name) VALUES ('settings');

INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('products', 1, (SELECT id FROM functional_areas WHERE functional_area_name = 'settings'));

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'products'
AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'settings')),
'Product types', '/list/product_types', 2);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'products'
AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'settings')),
'Type Names', '/list/packing_material_product_types', 2);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'products'
AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'settings')),
'Sub Type Names', '/list/packing_material_product_sub_types', 2);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'products'
AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'settings')),
'Products', '/list/products', 2);


-- retail_unit: %w(bag_fruit punnet tray protective bag_liner),
-- trade_unit: %w(carton bin lug),
-- logistics_unit: %w(pallet_base pallet_material),
-- label: %w(sticker fruit card ribbon),
-- other: %w(glue promotion sealing),

INSERT INTO packing_material_product_types (packing_material_type_name) VALUES ('retail unit'), ('trade unit'), ('logistics unit'),('label'),('other');

INSERT INTO packing_material_product_sub_types (packing_material_product_type_id, packing_material_sub_type_name)
SELECT pt.id, sub.str
FROM packing_material_product_types pt
JOIN (SELECT * FROM (VALUES ('bag fruit', 1), ('punnet',1 ), ('tray', 1), ('protective', 1), ('bag liner', 1)) AS t(str, n)) sub ON sub.n = 1
WHERE pt.packing_material_type_name = 'retail unit';

INSERT INTO packing_material_product_sub_types (packing_material_product_type_id, packing_material_sub_type_name)
SELECT pt.id, sub.str
FROM packing_material_product_types pt
JOIN (SELECT * FROM (VALUES ('carton', 1), ('bin',1 ), ('lug', 1)) AS t(str, n)) sub ON sub.n = 1
WHERE pt.packing_material_type_name = 'trade unit';

INSERT INTO packing_material_product_sub_types (packing_material_product_type_id, packing_material_sub_type_name)
SELECT pt.id, sub.str
FROM packing_material_product_types pt
JOIN (SELECT * FROM (VALUES ('pallet base', 1), ('pallet material',1 )) AS t(str, n)) sub ON sub.n = 1
WHERE pt.packing_material_type_name = 'logistics unit';

INSERT INTO packing_material_product_sub_types (packing_material_product_type_id, packing_material_sub_type_name)
SELECT pt.id, sub.str
FROM packing_material_product_types pt
JOIN (SELECT * FROM (VALUES ('sticker', 1), ('fruit',1 ), ('card', 1), ('ribbon', 1)) AS t(str, n)) sub ON sub.n = 1
WHERE pt.packing_material_type_name = 'label';

INSERT INTO packing_material_product_sub_types (packing_material_product_type_id, packing_material_sub_type_name)
SELECT pt.id, sub.str
FROM packing_material_product_types pt
JOIN (SELECT * FROM (VALUES ('glue', 1), ('promotion',1 ), ('sealing', 1)) AS t(str, n)) sub ON sub.n = 1
WHERE pt.packing_material_type_name = 'other';

INSERT INTO product_column_names (group_name, column_name)
VALUES ('classification', 'variant'),
       ('classification', 'style'),
       ('classification', 'assembly_type'),
       ('classification', 'market_major'),
       ('classification', 'commodity'),
       ('classification', 'variety'),
       ('classification', 'ctn_size_basic_pack'),
       ('classification', 'ctn_size_old_pack'),
       ('classification', 'pls_pack_code'),
       ('classification', 'fruit_mass_nett_kg'),
       ('classification', 'holes'),
       ('classification', 'perforation'),
       ('classification', 'image'),
       ('dimensions', 'length_mm'),
       ('dimensions', 'width_mm'),
       ('dimensions', 'height_mm'),
       ('dimensions', 'diameter_mm'),
       ('dimensions', 'thick_mm'),
       ('dimensions', 'thick_mic'),
       ('materials', 'colour'),
       ('materials', 'grade'),
       ('materials', 'mass'),
       ('materials', 'material_type'),
       ('materials', 'treatment'),
       ('materials', 'specification_notes'),
       ('artwork', 'artwork_commodity'),
       ('artwork', 'artwork_marketing_variety_group'),
       ('artwork', 'artwork_variety'),
       ('artwork', 'artwork_nett_mass'),
       ('artwork', 'artwork_brand'),
       ('artwork', 'artwork_class'),
       ('artwork', 'artwork_plu_number'),
       ('artwork', 'artwork_other'),
       ('artwork', 'artwork_image'),
       ('organizations', 'marketer'),
       ('organizations', 'retailer'),
       ('organizations', 'supplier'),
       ('organizations', 'supplier_stock_code'),
       ('inventory_management', 'product_alternative'),
       ('inventory_management', 'product_joint_use'),
       ('inventory_management', 'ownership'),
       ('inventory_management', 'consignment_stock'),
       ('inventory_management', 'start_date'),
       ('inventory_management', 'end_date'),
       ('inventory_management', 'active'),
       ('inventory_management', 'remarks');
