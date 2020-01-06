require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    run <<~SQL
      CREATE OR REPLACE FUNCTION public.fn_party_contact_method(in_id integer, in_method_type text)
        RETURNS text AS
      $BODY$
        SELECT string_agg(contact_methods.contact_method_code, ', ')
        FROM party_contact_methods
        JOIN contact_methods ON contact_methods.id = party_contact_methods.contact_method_id
        JOIN contact_method_types ON contact_method_types.id = contact_methods.contact_method_type_id
        WHERE party_contact_methods.party_id = in_id
          AND contact_method_types.contact_method_type = in_method_type;
      $BODY$
        LANGUAGE sql VOLATILE
        COST 100;
      ALTER FUNCTION public.fn_party_contact_method(integer, text)
        OWNER TO postgres;
    SQL
  end

  down do
    run 'DROP FUNCTION public.fn_party_contact_method(integer, text);'
  end
end
