# frozen_string_literal: true

module PackMaterialApp
  class SalesOrderCostInteractor < BaseInteractor
    def create_sales_order_cost(parent_id, params)
      res = validate_sales_order_cost_params(params.merge(mr_sales_order_id: parent_id))
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_sales_order_cost(res)
        log_status(:sales_order_costs, id, 'CREATED')
        log_transaction
      end
      instance = sales_order_cost(id)
      success_response('Created sales order cost', instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { id: ['This sales order cost already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_sales_order_cost(id, params)
      res = validate_sales_order_cost_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_sales_order_cost(id, res)
        log_transaction
      end
      instance = sales_order_cost(id)
      success_response('Updated sales order cost', instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_sales_order_cost(id)
      name = sales_order_cost(id).id
      repo.transaction do
        repo.delete_sales_order_cost(id)
        log_status(:sales_order_costs, id, 'DELETED')
        log_transaction
      end
      success_response("Deleted sales order cost #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::SalesOrderCost.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    private

    def repo
      @repo ||= DispatchRepo.new
    end

    def sales_order_cost(id)
      repo.find_sales_order_cost(id)
    end

    def validate_sales_order_cost_params(params)
      SalesOrderCostSchema.call(params)
    end
  end
end
