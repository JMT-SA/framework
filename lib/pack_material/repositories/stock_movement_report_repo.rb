# frozen_string_literal: true

module PackMaterialApp
  class StockMovementReportRepo < BaseRepo
    def stock_movement_report(start_date, end_date)
      # x = start_date
      # y = end_date

      # start date must be the 1 of the month
      # end date can be anything after the start date

      DB["select mrpv.id,
                 mrpv.product_variant_code,
                 (select sje.opening_balance
                  from stock_journal_entries sje
                  where sje.opening_balance_at < ('#{start_date}')::date and mrpv.id = sje.mr_product_variant_id
                  order by opening_balance_at desc limit 1),
                 fn_stock_quantity_received(mrpv.id, ('#{start_date}')::date, ('#{end_date}')::date),
                 fn_stock_quantity_returned(mrpv.id, ('#{start_date}')::date, ('#{end_date}')::date),
                 fn_stock_quantity_sold(mrpv.id, ('#{start_date}')::date, (#{end_date})::date),
                 (select (sje.opening_balance + fn_stock_total_at(mrpv.id,('#{start_date}')::date,('#{end_date}')::date))
                  from stock_journal_entries sje
                  where sje.opening_balance_at < ('#{start_date}')::date and mrpv.id = sje.mr_product_variant_id
                  order by opening_balance_at desc limit 1) as closing_balance
                 from material_resource_product_variants mrpv"].all
    end

    def stock_movement_report_records(start_date, end_date)
      x = start_date
      y = end_date

      x || y # tmp silence rubocop
    end
  end
end
