# require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    run <<~SQL
      CREATE OR REPLACE FUNCTION tf_protect_reserved_data()
        RETURNS trigger AS
      $BODY$
      DECLARE
        column_to_check text;
        fixed_values text[] = ARRAY[]::text[];
        this_value text;
      BEGIN
          IF TG_WHEN <> 'BEFORE' THEN
              RAISE EXCEPTION '% : tf_protect_reserved_data() may only run as a BEFORE trigger', TG_TABLE_NAME;
          END IF;

          IF TG_OP = 'INSERT' THEN
              RAISE EXCEPTION '% : tf_protect_reserved_data() may not run on INSERT trigger', TG_TABLE_NAME;
          END IF;

          IF TG_ARGV[0] IS NULL THEN
              RAISE EXCEPTION '% : tf_protect_reserved_data() requires "column_to_check" and "possible_values" parameters', TG_TABLE_NAME;
          ELSE
              column_to_check = quote_ident(TG_ARGV[0]);
          END IF;

          IF TG_ARGV[1] IS NULL THEN
              RAISE EXCEPTION '% : tf_protect_reserved_data() requires "possible_values" parameter', TG_TABLE_NAME;
          ELSE
              fixed_values = TG_ARGV[1]::text[];
          END IF;

          EXECUTE 'SELECT $1.' || column_to_check
             USING OLD
             INTO this_value;

          IF (this_value = ANY (fixed_values)) THEN
              RAISE EXCEPTION '[% : tf_protect_reserved_data] - % having % with value "%" cannot be changed or deleted - reserved by the system', TG_NAME, TG_TABLE_NAME, column_to_check, this_value;
              RETURN NULL;
          END IF;

          IF TG_OP = 'UPDATE' THEN
              RETURN NEW;
          ELSE
              RETURN OLD;
          END IF;
      END;
      $BODY$
        LANGUAGE plpgsql VOLATILE SECURITY DEFINER
        COST 100;
      ALTER FUNCTION tf_protect_reserved_data() SET search_path=pg_catalog, public;

      ALTER FUNCTION tf_protect_reserved_data()
        OWNER TO postgres;
      COMMENT ON FUNCTION tf_protect_reserved_data() IS '
      Block DELETE/UPDATE to a ROW if the row has a column with a reserved system value.

      This guards against system-required values in master tables being deleted or changed.

      -- For client-specific values (e.g. IMPLEMENTOR), Sequel migration will need
         to check an ENV VAR.

      Required parameters to trigger in CREATE TRIGGER call:

      param 0: text, the column name to check.

      param 1: text[], values to check for in the column.
      ';





      CREATE OR REPLACE FUNCTION tf_protect_reserved_data_fields()
        RETURNS trigger AS
      $BODY$
      DECLARE
        column_to_check text;
        fixed_values text[] = ARRAY[]::text[];
        this_value text;
        protected_columns text[] = ARRAY[]::text[];
        this_column text;
        old_string text;
        new_string text;
      BEGIN
          IF TG_WHEN <> 'BEFORE' THEN
              RAISE EXCEPTION '% : tf_protect_reserved_data_fields() may only run as a BEFORE trigger', TG_TABLE_NAME;
          END IF;

          IF TG_OP <> 'UPDATE' THEN
              RAISE EXCEPTION '% : tf_protect_reserved_data_fields() must be run on UPDATE trigger', TG_TABLE_NAME;
          END IF;

          IF TG_ARGV[0] IS NULL THEN
              RAISE EXCEPTION '% : tf_protect_reserved_data_fields() requires "column_to_check", "possible_values" and "protected_columns" parameters', TG_TABLE_NAME;
          ELSE
              column_to_check = quote_ident(TG_ARGV[0]);
          END IF;

          IF TG_ARGV[1] IS NULL THEN
              RAISE EXCEPTION '% : tf_protect_reserved_data_fields() requires "possible_values" and "protected_columns" parameters', TG_TABLE_NAME;
          ELSE
              fixed_values = TG_ARGV[1]::text[];
          END IF;

          IF TG_ARGV[2] IS NULL THEN
              RAISE EXCEPTION '% : tf_protect_reserved_data_fields() requires "protected_columns" parameter', TG_TABLE_NAME;
          ELSE
              protected_columns = TG_ARGV[2]::text[] || column_to_check;
          END IF;

          EXECUTE 'SELECT $1.' || column_to_check
             USING OLD
             INTO this_value;

          IF (this_value = ANY (fixed_values)) THEN
              FOREACH this_column IN ARRAY protected_columns
              LOOP
                  -- This only handles the case of text columns... (perhaps protected cols should be a 2D array including type)
                  EXECUTE 'SELECT $1.' || this_column
                     USING OLD
                     INTO old_string;
                  EXECUTE 'SELECT $1.' || this_column
                     USING NEW
                     INTO new_string;
                  IF old_string IS DISTINCT FROM new_string THEN
                    RAISE EXCEPTION '[% : tf_protect_reserved_data_fields] - % having % with value "%" cannot be changed - reserved by the system', TG_NAME, TG_TABLE_NAME, column_to_check, this_value;
                    RETURN NULL;
                  END IF;
              END LOOP;
              RETURN NEW;
          END IF;
          RETURN NEW;
      END;
      $BODY$
        LANGUAGE plpgsql VOLATILE SECURITY DEFINER
        COST 100;
      ALTER FUNCTION tf_protect_reserved_data_fields() SET search_path=pg_catalog, public;

      ALTER FUNCTION tf_protect_reserved_data_fields()
        OWNER TO postgres;
      COMMENT ON FUNCTION tf_protect_reserved_data_fields() IS '
      Block UPDATE to a ROW if the row has a column with a reserved system value and any of a set of columns are changed.

      This guards against system-required values in master tables being changed.

      -- For client-specific values (e.g. IMPLEMENTOR), Sequel migration will need
         to check an ENV VAR.

      Required parameters to trigger in CREATE TRIGGER call:

      param 0: text, the column name to check.

      param 1: text[], values to check for in the column.

      param 2: text[], columns to protect from updating.
      ';



      CREATE OR REPLACE FUNCTION set_reserved_data_on_table(
          target_table regclass,
          column_to_check text,
          fixed_values text[],
          protected_columns text[])
        RETURNS void AS
      $BODY$
      DECLARE
        _q_txt text;
      BEGIN
          EXECUTE 'DROP TRIGGER IF EXISTS check_for_reserved_data ON ' || quote_ident(target_table::TEXT);
          EXECUTE 'DROP TRIGGER IF EXISTS check_for_reserved_data_upd ON ' || quote_ident(target_table::TEXT);
          EXECUTE 'DROP TRIGGER IF EXISTS check_for_reserved_data_del ON ' || quote_ident(target_table::TEXT);

          IF array_length(protected_columns, 1) > 0 THEN
            -- upd
              _q_txt = 'CREATE TRIGGER check_for_reserved_data_upd BEFORE UPDATE ON ' ||
                       quote_ident(target_table::TEXT) ||
                       ' FOR EACH ROW EXECUTE PROCEDURE tf_protect_reserved_data_fields(' ||
                       quote_literal(column_to_check) || ', ' || quote_literal(fixed_values) ||
                       ', ' || quote_literal(protected_columns) || ');';
              RAISE NOTICE '%',_q_txt;
              EXECUTE _q_txt;
            -- del
              _q_txt = 'CREATE TRIGGER check_for_reserved_data_del BEFORE DELETE ON ' ||
                       quote_ident(target_table::TEXT) ||
                       ' FOR EACH ROW EXECUTE PROCEDURE tf_protect_reserved_data(' ||
                       quote_literal(column_to_check) || ', ' || quote_literal(fixed_values) || ');';
              RAISE NOTICE '%',_q_txt;
              EXECUTE _q_txt;
          ELSE
              _q_txt = 'CREATE TRIGGER check_for_reserved_data BEFORE UPDATE OR DELETE ON ' ||
                       quote_ident(target_table::TEXT) ||
                       ' FOR EACH ROW EXECUTE PROCEDURE tf_protect_reserved_data(' ||
                       quote_literal(column_to_check) || ', ' || quote_literal(fixed_values) || ');';
              RAISE NOTICE '%',_q_txt;
              EXECUTE _q_txt;
          END IF;

      END;
      $BODY$
        LANGUAGE plpgsql VOLATILE
        COST 100;
      ALTER FUNCTION set_reserved_data_on_table(regclass, text, text[], text[])
        OWNER TO postgres;
      COMMENT ON FUNCTION set_reserved_data_on_table(regclass, text, text[], text[]) IS '
      Add ability to protect reserved values in a table.
      e.g. block delete of "CUSTOMER" in a roles table.

      Arguments:
         target_table:      Table name, schema qualified if not on search_path
         column_to_check:   Column name to check for values in fixed_values.
         fixed_values:      Values that are reserved in this table (should not be deleted/changed).
         protected_columns: Columns to protect from update. If left out, no column in the record can be updated.
      ';


      CREATE OR REPLACE FUNCTION set_reserved_data_on_table(
          target_table regclass,
          column_to_check text,
          fixed_values text[])
        RETURNS void AS
      $BODY$
      SELECT set_reserved_data_on_table($1, $2, $3, ARRAY[]::text[]);
      $BODY$
        LANGUAGE sql VOLATILE
        COST 100;
      ALTER FUNCTION set_reserved_data_on_table(regclass, text, text[])
        OWNER TO postgres;
    SQL
  end

  down do
    run <<~SQL
      DROP FUNCTION public.set_reserved_data_on_table(regclass, text, text[]);
      DROP FUNCTION public.set_reserved_data_on_table(regclass, text, text[], text[]);
      DROP FUNCTION public.tf_protect_reserved_data();
      DROP FUNCTION public.tf_protect_reserved_data_fields();
    SQL
  end
end
