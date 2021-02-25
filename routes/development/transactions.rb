# frozen_string_literal: true

class Framework < Roda
  route 'transactions', 'development' do |r|
    # TRANSACTION LOGS
    # --------------------------------------------------------------------------
    r.on 'list', String, Integer do |table, id|
      show_partial_or_page(r) { Development::Transactions::Transaction::List.call(table, id) }
    end
  end
end
