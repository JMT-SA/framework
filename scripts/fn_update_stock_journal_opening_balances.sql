-- The purpose of this function is to have a procedure that can be run monthly to keep the stock journals up to date
create or replace function fn_update_stock_journal_opening_balances(opening_balance_at_date date) returns integer
    language sql-- NOTE: The opening balance at date will always be the first of the month
as

$$
INSERT INTO stock_journal_entries (mr_product_variant_id, opening_balance, opening_balance_at)
SELECT mrpv.id,
       (select stock_journal_entries.opening_balance
        from stock_journal_entries
        where mr_product_variant_id = mrpv.id
        order by opening_balance_at desc limit 1)
           + fn_stock_total_at(mrpv.id, (opening_balance_at_date - interval '1 months')::date, opening_balance_at_date) as new_total,
       opening_balance_at_date
FROM material_resource_product_variants mrpv;
$$;

alter function fn_update_stock_journal_opening_balances(integer, date, date) owner to postgres;