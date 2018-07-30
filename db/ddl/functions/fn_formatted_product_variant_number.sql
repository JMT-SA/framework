-- Function: public.fn_formatted_product_variant_number(bigint)

-- DROP FUNCTION public.fn_formatted_product_variant_number(bigint);

CREATE OR REPLACE FUNCTION public.fn_formatted_product_variant_number(in_number bigint)
  RETURNS text AS
$BODY$
  SELECT to_char(in_number, 'FM99-99-99-999-999')
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.fn_formatted_product_variant_number(bigint)
  OWNER TO postgres;

-- TO USE in a query:
-- SELECT fn_formatted_product_variant_number(pack_material_product_variants.product_variant_number) AS product_variant_number
