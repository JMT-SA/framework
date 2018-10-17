Sequel.migration do
  up do
    run <<~SQL
      CREATE OR REPLACE FUNCTION public.fn_current_status(
          in_table text,
          in_id integer)
        RETURNS text AS
      $BODY$
        SELECT CONCAT_WS(' ', status, comment) AS status
        FROM audit.current_statuses
        WHERE table_name = in_table
          AND row_data_id = in_id
      $BODY$
        LANGUAGE sql VOLATILE
        COST 100;
      ALTER FUNCTION public.fn_current_status(text, integer)
        OWNER TO postgres;
    SQL
  end

  down do
    run <<~SQL
      DROP FUNCTION public.fn_current_status(text, integer);
    SQL
  end
end
