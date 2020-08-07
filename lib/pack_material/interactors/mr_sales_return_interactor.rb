# frozen_string_literal: true

module PackMaterialApp
  class MrSalesReturnInteractor < BaseInteractor
    def create_mr_sales_return(params)
      res = validate_mr_sales_return_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_mr_sales_return(res)
        log_status(:mr_sales_returns, id, 'CREATED')
        log_transaction
      end
      instance = mr_sales_return(id)
      success_response("Created sales return #{instance.created_by}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { created_by: ['This sales return already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_mr_sales_return(id, params)
      res = validate_mr_sales_return_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.update_mr_sales_return(id, res)
        log_transaction
      end
      instance = mr_sales_return(id)
      success_response("Updated sales return #{instance.created_by}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_mr_sales_return(id)
      name = mr_sales_return(id).created_by
      repo.transaction do
        repo.delete_mr_sales_return(id)
        log_status(:mr_sales_returns, id, 'DELETED')
        log_transaction
      end
      success_response("Deleted sales return #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::MrSalesReturn.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    private

    def repo
      @repo ||= DispatchRepo.new
    end

    def mr_sales_return(id)
      repo.find_mr_sales_return(id)
    end

    def validate_mr_sales_return_params(params)
      MrSalesReturnSchema.call(params)
    end
  end
end
