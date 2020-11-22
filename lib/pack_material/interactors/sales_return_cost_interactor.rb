# frozen_string_literal: true

module PackMaterialApp
  class SalesReturnCostInteractor < BaseInteractor
    def create_sales_return_cost(parent_id, params) # rubocop:disable Metrics/AbcSize
      res = validate_sales_return_cost_params(params.merge(mr_sales_return_id: parent_id))
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_sales_return_cost(res)
        log_status(:sales_return_costs, id, 'CREATED')
        log_transaction
      end
      instance = sales_return_cost(id)
      success_response("Created sales return cost #{instance.id}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { id: ['This sales return cost already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_sales_return_cost(id, params)
      res = validate_sales_return_cost_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_sales_return_cost(id, res)
        log_transaction
      end
      instance = sales_return_cost(id)
      success_response("Updated sales return cost #{instance.id}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_sales_return_cost(id)
      name = sales_return_cost(id).id
      repo.transaction do
        repo.delete_sales_return_cost(id)
        log_status(:sales_return_costs, id, 'DELETED')
        log_transaction
      end
      success_response("Deleted sales return cost #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::SalesReturnCost.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def sales_return_sub_totals(sales_return_id)
      repo.sales_return_sub_totals(sales_return_id)
    end

    private

    def repo
      @repo ||= SalesReturnRepo.new
    end

    def sales_return_cost(id)
      repo.find_sales_return_cost(id)
    end

    def validate_sales_return_cost_params(params)
      SalesReturnCostSchema.call(params)
    end
  end
end
