DELETE FROM material_resource_product_columns;

-- Make seed for all the product columns for this domain - ALSO NO CRUD
INSERT INTO material_resource_product_columns (material_resource_domain_id, column_name, short_code, description)
SELECT dom.id, sub.column_name, sub.short_code, sub.description
FROM material_resource_domains dom
JOIN (SELECT * FROM (VALUES ('unit', 'UNIT', 'Unit', 1),
  ('style', 'STYL', 'Style', 1),
  ('alternate', 'ALTE', 'Alternate', 1),
  ('shape', 'SHPE', 'Shape', 1),
  ('reference_size', 'REFS', 'Reference Size', 1),
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
  ('length_mm', 'LGTH', 'This will display concatenated for Reference Dimension.', 1),
  ('width_mm', 'WDTH', 'This will display concatenated for Reference Dimension.', 1),
  ('height_mm', 'HGHT', 'This will display concatenated for Reference Dimension.', 1),
  ('diameter_mm', 'DIAM', 'This will display concatenated for Reference Dimension.', 1),
  ('thick_mm', 'THMM', 'This will display concatenated for Reference Dimension.', 1),
  ('thick_mic', 'THMC', 'This will display concatenated for Reference Dimension.', 1),
  ('other', 'OTHR', 'Other', 1))
  AS t(column_name, short_code, description, n)) sub ON sub.n = 1
WHERE dom.domain_name = 'Packing Materials';

