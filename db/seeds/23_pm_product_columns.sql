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
