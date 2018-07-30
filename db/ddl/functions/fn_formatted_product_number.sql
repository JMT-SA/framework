-- Function: public.fn_formatted_product_number(integer)

-- DROP FUNCTION public.fn_formatted_product_number(integer);

CREATE OR REPLACE FUNCTION public.fn_formatted_product_number(in_number integer)
  RETURNS text AS
$BODY$
  SELECT to_char(in_number, 'FM99-99-99-999')
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.fn_formatted_product_number(integer)
  OWNER TO postgres;

-- TO USE in a query:
-- SELECT fn_formatted_product_number(pack_material_products.product_number) AS product_number
