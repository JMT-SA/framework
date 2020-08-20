# frozen_string_literal: true

module PackMaterialApp
  class CreateSalesReturnSKUS < BaseService
    def initialize(sales_return_id, user_name)
      @id = sales_return_id
      @repo = SalesReturnRepo.new
      @stock_repo = MrStockRepo.new
      @sales_return = @repo.find_mr_sales_return(@id)
      @user_name = user_name
    end

    def call
      return failed_response('Sales Return record does not exist') unless @sales_return

      sales_return_stock_items = @repo.sales_return_stock_items(@id)
      sku_ids = sales_return_stock_items.map { |h| h[:sku_id] }

      to_loc_id = @sales_return.receipt_location_id

      @repo.log_status('mr_sales_returns', @id, 'SKUS_CREATED')
      business_process_id = @stock_repo.resolve_business_process_id(is_adhoc: true)

      CreateMrStock.call(sku_ids,
                         business_process_id: business_process_id,
                         to_location_id: to_loc_id,
                         user_name: @user_name,
                         ref_no: @sales_return.sales_return_number,
                         quantities: sales_return_stock_items)
    end
  end
end
