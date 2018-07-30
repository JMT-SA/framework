Sequel.migration do
  up do
    run <<~SQL
      CREATE OR REPLACE FUNCTION public.material_resource_domain_internal_seq_incr()
      RETURNS trigger AS
    $BODY$
      DECLARE
        p_sql INTEGER;
    BEGIN
        EXECUTE 'SELECT MAX(m.internal_seq) AS latest_no FROM material_resource_domains m' INTO p_sql;
        IF p_sql IS NULL THEN
          p_sql = 9;
        END IF;

        NEW.internal_seq = p_sql + 1;
      RETURN NEW;
    END
    $BODY$
      LANGUAGE plpgsql VOLATILE
      COST 100;
    ALTER FUNCTION public.material_resource_domain_internal_seq_incr()
      OWNER TO postgres;

      CREATE TRIGGER material_resource_domain_internal_seq_incr
      BEFORE INSERT
      ON public.material_resource_domains
      FOR EACH ROW
      EXECUTE PROCEDURE public.material_resource_domain_internal_seq_incr();
    SQL

    run <<~SQL
      CREATE OR REPLACE FUNCTION public.material_resource_type_internal_seq_incr()
      RETURNS trigger AS
    $BODY$
      DECLARE
        p_sql INTEGER;
    BEGIN
        EXECUTE 'SELECT MAX(m.internal_seq) AS latest_no FROM material_resource_types m WHERE m.material_resource_domain_id = $1' INTO p_sql USING NEW.material_resource_domain_id;
        IF p_sql IS NULL THEN
          p_sql = 0;
        END IF;

        NEW.internal_seq = p_sql + 1;
      RETURN NEW;
    END
    $BODY$
      LANGUAGE plpgsql VOLATILE
      COST 100;
    ALTER FUNCTION public.material_resource_type_internal_seq_incr()
      OWNER TO postgres;

      CREATE TRIGGER material_resource_type_internal_seq_incr
      BEFORE INSERT
      ON public.material_resource_types
      FOR EACH ROW
      EXECUTE PROCEDURE public.material_resource_type_internal_seq_incr();
    SQL

    run <<~SQL
      CREATE OR REPLACE FUNCTION public.material_resource_sub_type_internal_seq_incr()
      RETURNS trigger AS
    $BODY$
      DECLARE
        p_sql INTEGER;
    BEGIN
        EXECUTE 'SELECT MAX(m.internal_seq) AS latest_no FROM material_resource_sub_types m WHERE m.material_resource_type_id = $1' INTO p_sql USING NEW.material_resource_type_id;
        IF p_sql IS NULL THEN
          p_sql = 0;
        END IF;

        NEW.internal_seq = p_sql + 1;
      RETURN NEW;
    END
    $BODY$
      LANGUAGE plpgsql VOLATILE
      COST 100;
    ALTER FUNCTION public.material_resource_sub_type_internal_seq_incr()
      OWNER TO postgres;

      CREATE TRIGGER material_resource_sub_type_internal_seq_incr
      BEFORE INSERT
      ON public.material_resource_sub_types
      FOR EACH ROW
      EXECUTE PROCEDURE public.material_resource_sub_type_internal_seq_incr();
    SQL
  end

  down do
    run <<~SQL
      DROP TRIGGER material_resource_sub_type_internal_seq_incr ON public.material_resource_sub_types;
      DROP FUNCTION public.material_resource_sub_type_internal_seq_incr();

      DROP TRIGGER material_resource_type_internal_seq_incr ON public.material_resource_types;
      DROP FUNCTION public.material_resource_type_internal_seq_incr();

      DROP TRIGGER material_resource_domain_internal_seq_incr ON public.material_resource_domains;
      DROP FUNCTION public.material_resource_domain_internal_seq_incr();
    SQL
  end
end
