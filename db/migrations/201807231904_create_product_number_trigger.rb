Sequel.migration do
  up do
    run <<~SQL
      CREATE OR REPLACE FUNCTION public.pack_material_product_update_number()
        RETURNS trigger AS
      $BODY$
        DECLARE
          p_sql INTEGER;
      BEGIN

          EXECUTE 'SELECT MAX(p.product_number) AS latest_no FROM pack_material_products p WHERE p.material_resource_sub_type_id = $1' INTO p_sql USING NEW.material_resource_sub_type_id;
          IF p_sql IS NULL THEN
            EXECUTE 'SELECT (to_char(d.internal_seq, ''fm00'') || to_char(t.internal_seq, ''fm00'') || to_char(s.internal_seq, ''fm00'') || ''000'')::integer FROM material_resource_sub_types  s JOIN material_resource_types t ON t.id = s.material_resource_type_id JOIN material_resource_domains d ON d.id = t.material_resource_domain_id WHERE s.id = $1' INTO p_sql USING NEW.material_resource_sub_type_id;
          END IF;

          NEW.product_number = p_sql + 1;
        RETURN NEW;

      END
      $BODY$
        LANGUAGE plpgsql VOLATILE
        COST 100;
      ALTER FUNCTION public.pack_material_product_update_number()
        OWNER TO postgres;

      CREATE TRIGGER pack_material_product_update_number
      BEFORE INSERT
      ON public.pack_material_products
      FOR EACH ROW
      EXECUTE PROCEDURE public.pack_material_product_update_number();

    SQL
  end

  down do
    run <<~SQL
      DROP TRIGGER pack_material_product_update_number ON public.pack_material_products;
      DROP FUNCTION public.pack_material_product_update_number();
    SQL
  end
end
