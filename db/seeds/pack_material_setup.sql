-- This is created in the backend per domain - NO CRUD AVAILABLE for users
INSERT INTO material_resource_domains (domain_name, product_table_name, variant_table_name)
VALUES ('Pack Material', 'pack_material_products', 'pack_material_product_variants');

-- Menu Structure
INSERT INTO functional_areas (functional_area_name)
VALUES ('Pack Material');

INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Configuration', 1, (SELECT id FROM functional_areas WHERE functional_area_name = 'Pack Material'));

INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs WHERE program_name = 'Configuration' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Pack Material')), 'Framework');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Configuration'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'Types', '/list/material_resource_types', 1);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Configuration'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'Sub Types', '/list/material_resource_sub_types', 2);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Configuration'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'Products', '/list/pack_material_products', 3); -- Used to be 'Product Codes'

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Configuration'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'Product codes', '/list/pack_material_product_variants', 4); -- Used to be 'Product Variants'

-- All product columns for Pack Material domain - NO CRUD AVAILABLE
DELETE FROM material_resource_product_columns;

INSERT INTO material_resource_product_columns (material_resource_domain_id, column_name, short_code, description)
  SELECT dom.id, sub.column_name, sub.short_code, sub.description
  FROM material_resource_domains dom
    JOIN (SELECT * FROM (VALUES ('unit', 'UNIT', 'Unit', 1),
      ('style', 'STYL', 'Style', 1),
      ('alternate', 'ALTE', 'Alternate', 1),
      ('shape', 'SHPE', 'Shape', 1),
      ('reference_size', 'REFS', 'Reference Size', 1),
      ('reference_dimension', 'REFD', 'Reference Dimension', 1),
      ('reference_quantity', 'REFQ', 'Reference Quantity', 1),
      ('brand_1', 'BRD1', 'Brand1', 1),
      ('brand_2', 'BRD2', 'Brand2', 1),
      ('colour', 'COLR', 'Colour', 1),
      ('material', 'MATR', 'Material', 1),
      ('assembly', 'ASSM', 'Assembly', 1),
      ('reference_mass', 'REFM', 'Reference Mass', 1),
      ('reference_number', 'REFN', 'Reference Number', 1),
      ('market', 'MRKT', 'Market', 1),
      ('marking', 'MARK', 'Marking', 1),
      ('model', 'MODL', 'Model', 1),
      ('pm_class', 'CLAS', 'Class', 1),
      ('grade', 'GRAD', 'Grade', 1),
      ('language', 'LANG', 'Language', 1),
      ('other', 'OTHR', 'Other', 1),
      ('commodity_id', 'COMM', 'Commodity', 1),
      ('marketing_variety_id', 'VARY', 'Variety', 1))
      AS t(column_name, short_code, description, n)) sub ON sub.n = 1
  WHERE dom.domain_name = 'Pack Material';



-- PROGRAM: material_resource
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('material_resource', 2,
        (SELECT id FROM functional_areas WHERE functional_area_name = 'Pack Material'));

-- LINK program to webapp
INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs
WHERE program_name = 'material_resource'
      AND functional_area_id = (SELECT id
                                FROM functional_areas
                                WHERE functional_area_name = 'Pack Material')),
        'Framework');

INSERT INTO uom_types (code) VALUES ('INVENTORY');
