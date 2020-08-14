# frozen_string_literal: true

module PackMaterialApp
  class MrSalesReturnInteractor < BaseInteractor
    def create_mr_sales_return(params)  # rubocop:disable Metrics/AbcSize
      res = validate_new_mr_sales_return_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_mr_sales_return(res.to_h.merge(created_by: @user.user_name))
        log_status(:mr_sales_returns, id, 'CREATED')
        log_transaction
      end
      instance = mr_sales_return(id)
      success_response("Created sales return #{instance.sales_return_number}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { base: ['This sales return already exists'] }))
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
      success_response("Updated sales return #{instance.sales_return_number}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_mr_sales_return(id)
      number = mr_sales_return(id).sales_return_number
      repo.transaction do
        repo.delete_mr_sales_return(id)
        log_status(:mr_sales_returns, id, 'DELETED')
        log_transaction
      end
      success_response("Deleted sales return #{number}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def verify_sales_return(id)
      instance = mr_sales_return(id)
      success_response("Verified sales return #{instance.sales_return_number}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def complete_sales_return(id)
      instance = mr_sales_return(id)
      success_response("Completed sales return #{instance.sales_return_number}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def assert_permission!(task, id = nil)
      res = check_permission(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def check_permission(task, id = nil)
      TaskPermissionCheck::MrSalesReturn.call(task, id, current_user: @user)
    end

    private

    def repo
      @repo ||= SalesReturnRepo.new
    end

    def mr_sales_return(id)
      repo.find_mr_sales_return(id)
    end

    def validate_new_mr_sales_return_params(params)
      NewMrSalesReturnSchema.call(params)
    end

    def validate_mr_sales_return_params(params)
      MrSalesReturnSchema.call(params)
    end
  end
end
