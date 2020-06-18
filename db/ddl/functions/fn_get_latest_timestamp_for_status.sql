CREATE OR REPLACE FUNCTION public.fn_get_latest_timestamp_for_status(
    in_table text,
    in_status text,
    in_id integer)
    RETURNS timestamp with time zone AS
$BODY$
SELECT action_tstamp_tx
FROM audit.status_logs
WHERE table_name = in_table
  AND row_data_id = in_id
  AND status = in_status
ORDER BY action_tstamp_tx desc limit 1
$BODY$
    LANGUAGE sql VOLATILE
                 COST 100;
ALTER FUNCTION public.fn_get_latest_timestamp_for_status(text, text, integer)
    OWNER TO postgres;
