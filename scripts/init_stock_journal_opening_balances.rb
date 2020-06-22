# frozen_string_literal: true

# require 'logger'
class InitStockJournalOpeningBalances < BaseScript
  def run # rubocop:disable Metrics/AbcSize
    sql_info = ['Initiate opening balances for Periodic Stock Report.']

    dates = DB["select generate_series(('2019_07_01')::date, ('2020_06_01')::date, interval '1 month');"].all.map { |r| r[:generate_series].strftime('%Y-%m-%d') }
    dates.each do |date|
      script = %(INSERT INTO stock_journal_entries (mr_product_variant_id, opening_balance, opening_balance_on)
                  SELECT mrpv.id, fn_stock_total_at(mrpv.id, ('2019_01_01')::date, ('#{date}')::date), ('#{date}')::date
                  FROM material_resource_product_variants mrpv;)
      sql_info << script
      if debug_mode
        puts script
        puts ''
        p sql_info
      else
        DB.transaction do
          DB.run(script)
        end
      end
    end

    log_infodump(:initialize,
                 :stock_journal_entries,
                 :set_opening_balances,
                 sql_info.join("\n"))

    if debug_mode
      success_response('Dry run complete')
    else
      success_response('Initiated Stock Journal Opening Balances')
    end
  end
end
