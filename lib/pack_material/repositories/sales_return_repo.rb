# frozen_string_literal: true

module PackMaterialApp
  class SalesReturnRepo < BaseRepo
    build_for_select :mr_sales_returns,
                     label: :created_by,
                     value: :id,
                     no_active_check: true,
                     order_by: :created_by

    crud_calls_for :mr_sales_returns, name: :mr_sales_return, wrapper: MrSalesReturn
  end
end
