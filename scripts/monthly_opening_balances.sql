INSERT INTO stock_journal_entries (mr_product_variant_id, opening_balance, opening_balance_on)
SELECT mrpv.id,
       (select stock_journal_entries.opening_balance
        from stock_journal_entries
        where mr_product_variant_id = mrpv.id
        order by opening_balance_on desc limit 1)
           + fn_stock_total_at(mrpv.id, (date_trunc('month', current_date)::date - interval '1 months')::date, date_trunc('month', current_date)::date) as new_total,
       date_trunc('month', current_date)::date
FROM material_resource_product_variants mrpv;