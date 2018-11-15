Sequel.migration do
  up do
    run <<~SQL
      CREATE OR REPLACE FUNCTION public.pack_material_product_update_code()
        RETURNS trigger AS
      $BODY$
        DECLARE
          o_code TEXT DEFAULT '';
          p_sep TEXT;
          p_type TEXT;
          p_sub TEXT;
          p_col TEXT;
          p_sql TEXT;
          cur_cols CURSOR (sub_type_id integer) FOR SELECT pc.column_name
            FROM
             unnest((SELECT st.product_code_ids FROM material_resource_sub_types st WHERE st.id = sub_type_id)) WITH ORDINALITY t(id, ord)
             LEFT JOIN material_resource_product_columns pc on pc.id = t.id
             ORDER BY t.ord;
      BEGIN

          EXECUTE 'SELECT s.product_code_separator, t.short_code, s.short_code FROM material_resource_sub_types s JOIN material_resource_types t ON t.id = s.material_resource_type_id WHERE s.id = $1' INTO p_sep, p_type, p_sub USING NEW.material_resource_sub_type_id;

          OPEN cur_cols(sub_type_id:=NEW.material_resource_sub_type_id);

          LOOP
            FETCH cur_cols INTO p_col;
            EXIT WHEN NOT FOUND;

            IF p_col = 'commodity_id' THEN
              EXECUTE 'SELECT code FROM commodities WHERE id = $1' INTO p_sql USING NEW.commodity_id;
            ELSIF p_col = 'marketing_variety_id' THEN
              EXECUTE 'SELECT marketing_variety_code FROM marketing_varieties WHERE id = $1' INTO p_sql USING NEW.marketing_variety_id;
            ELSE
              EXECUTE format('SELECT ($1).%s::text', p_col)
               USING NEW
               INTO  p_sql;
            END IF;

            IF o_code = '' THEN
              o_code := o_code || p_type || p_sep || p_sub || p_sep || p_sql;
            ELSE
              o_code := o_code || p_sep || p_sql;
            END IF;
          END LOOP;

          CLOSE cur_cols;
          NEW.product_code = COALESCE(o_code, 'PLEASE SELECT COLUMNS');
        RETURN NEW;

      END
      $BODY$
        LANGUAGE plpgsql VOLATILE
        COST 100;
      ALTER FUNCTION public.pack_material_product_update_code()
        OWNER TO postgres;
    SQL
  end

  down do
    # run <<~SQL
    #   DROP FUNCTION public.pack_material_product_update_code();
    # SQL
  end
end
