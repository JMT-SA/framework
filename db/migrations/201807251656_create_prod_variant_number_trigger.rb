Sequel.migration do
  up do
    run <<~SQL
      CREATE OR REPLACE FUNCTION public.pack_material_product_variant_update_number()
        RETURNS trigger AS
      $BODY$
        DECLARE
          p_sql BIGINT;
      BEGIN

          EXECUTE 'SELECT MAX(p.product_variant_number) AS latest_no FROM pack_material_product_variants p WHERE p.pack_material_product_id = $1' INTO p_sql USING NEW.pack_material_product_id;
          IF p_sql IS NULL THEN
            EXECUTE 'SELECT (product_number::text || ''000'')::bigint FROM pack_material_products WHERE id = $1' INTO p_sql USING NEW.pack_material_product_id;
          END IF;

          NEW.product_variant_number = p_sql + 1;
        RETURN NEW;

      END
      $BODY$
        LANGUAGE plpgsql VOLATILE
        COST 100;
      ALTER FUNCTION public.pack_material_product_variant_update_number()
        OWNER TO postgres;

      CREATE TRIGGER pack_material_product_variant_update_number
      BEFORE INSERT
      ON public.pack_material_product_variants
      FOR EACH ROW
      EXECUTE PROCEDURE public.pack_material_product_variant_update_number();

    SQL
  end

  down do
    run <<~SQL
      DROP TRIGGER pack_material_product_variant_update_number ON public.pack_material_product_variants;
      DROP FUNCTION public.pack_material_product_variant_update_number();
    SQL
  end
end
