-- Function: public.fn_product_type_name(integer)

-- DROP FUNCTION public.fn_product_type_name(integer);

CREATE OR REPLACE FUNCTION public.fn_product_type_name(in_id integer)
  RETURNS text AS
$BODY$
SELECT DISTINCT COALESCE(INITCAP(pmpt.packing_material_type_name) || ', ' || initcap(pmpst.packing_material_sub_type_name)) AS product_type_name
FROM product_types pt
  LEFT OUTER JOIN packing_material_product_types pmpt ON pmpt.id = pt.packing_material_product_type_id
  LEFT OUTER JOIN packing_material_product_sub_types pmpst ON pmpst.id = pt.packing_material_product_sub_type_id
$BODY$
LANGUAGE sql VOLATILE
COST 100;
ALTER FUNCTION public.fn_product_type_name(integer)
OWNER TO postgres;
