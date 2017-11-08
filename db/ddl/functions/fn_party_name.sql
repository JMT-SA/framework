-- Function: public.fn_party_name(integer)

-- DROP FUNCTION public.fn_party_name(integer);

CREATE OR REPLACE FUNCTION public.fn_party_name(in_id integer)
  RETURNS text AS
$BODY$
SELECT DISTINCT COALESCE(o.short_description, p.first_name || ' ' || p.surname) AS party_name
  FROM party_roles pr
  LEFT OUTER JOIN organizations o ON o.id = pr.organization_id
  LEFT OUTER JOIN people p ON p.id = pr.person_id
  JOIN parties y ON y.id = pr.party_id
  WHERE y.id = in_id
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.fn_party_name(integer)
  OWNER TO postgres;
