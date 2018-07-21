Sequel.migration do
  up do
    run <<~SQL
      CREATE OR REPLACE FUNCTION public.pack_material_product_update_code()
        RETURNS trigger AS
      $BODY$
        DECLARE
          o_code TEXT DEFAULT '';
          p_sep TEXT;
          p_col TEXT;
          p_sql TEXT;
          cur_cols CURSOR (sub_type_id integer) FOR SELECT sub.product_code_separator, m.column_name
            FROM 
            (SELECT s.product_code_separator, unnest(s.product_code_ids) AS pcid
             FROM material_resource_sub_types s
             WHERE s.id = sub_type_id) AS sub
            LEFT JOIN material_resource_product_columns m ON m.id = sub.pcid;
      BEGIN

          OPEN cur_cols(sub_type_id:=NEW.material_resource_sub_type_id);

          LOOP
            FETCH cur_cols INTO p_sep, p_col;
            EXIT WHEN NOT FOUND;

            IF p_col = 'commodity_id' THEN
              EXECUTE 'SELECT code FROM commodities WHERE id = $1' INTO p_sql USING NEW.commodity_id;
            ELSIF p_col = 'variety_id' THEN
              EXECUTE 'SELECT marketing_variety_code FROM marketing_varieties WHERE id = $1' INTO p_sql USING NEW.variety_id;
            ELSE
              EXECUTE format('SELECT ($1).%s::text', p_col)
               USING NEW
               INTO  p_sql;
            END IF;

            IF o_code = '' THEN
              o_code := o_code || p_sql;
            ELSE
              o_code := o_code || p_sep || p_sql;
            END IF;
          END LOOP;

          CLOSE cur_cols;
          NEW.product_code = o_code;
        RETURN NEW;

      END
      $BODY$
        LANGUAGE plpgsql VOLATILE
        COST 100;
      ALTER FUNCTION public.pack_material_product_update_code()
        OWNER TO postgres;

      CREATE TRIGGER pack_material_product_update_code
      BEFORE INSERT OR UPDATE
      ON public.pack_material_products
      FOR EACH ROW
      EXECUTE PROCEDURE public.pack_material_product_update_code();

    SQL
  end

  down do
    run <<~SQL
      DROP TRIGGER pack_material_product_update_code ON public.pack_material_products;
      DROP FUNCTION public.pack_material_product_update_code();
    SQL
  end
end
