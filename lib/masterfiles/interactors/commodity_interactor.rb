# frozen_string_literal: true

module MasterfilesApp
  class CommodityInteractor < BaseInteractor
    def create_commodity_group(params)
      res = validate_commodity_group_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_commodity_group(res)
      instance = commodity_group(id)
      success_response("Created commodity group #{instance.code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { code: ['This commodity group already exists'] }))
    end

    def update_commodity_group(id, params)
      res = validate_commodity_group_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_commodity_group(id, res)
      instance = commodity_group(id)
      success_response("Updated commodity group #{instance.code}", instance)
    end

    def delete_commodity_group(id)
      name = commodity_group(id).code
      res = {}
      repo.transaction do
        res = repo.delete_commodity_group(id)
      end
      if res[:error]
        failed_response(res[:error])
      else
        success_response("Deleted commodity group #{name}")
      end
    end

    def create_commodity(params)
      res = validate_commodity_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_commodity(res)
      instance = commodity(id)
      success_response("Created commodity #{instance.code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { code: ['This commodity already exists'] }))
    end

    def update_commodity(id, params)
      res = validate_commodity_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_commodity(id, res)
      instance = commodity(id)
      success_response("Updated commodity #{instance.code}", instance)
    end

    def delete_commodity(id)
      name = commodity(id).code
      res = {}
      repo.transaction do
        res = repo.delete_commodity(id)
      end
      if res[:error]
        failed_response(res[:error])
      else
        success_response("Deleted commodity #{name}")
      end
    end

    private

    def repo
      @repo ||= CommodityRepo.new
    end

    def commodity_group(id)
      repo.find_commodity_group(id)
    end

    def validate_commodity_group_params(params)
      CommodityGroupSchema.call(params)
    end

    def commodity(id)
      repo.find_commodity(id)
    end

    def validate_commodity_params(params)
      CommoditySchema.call(params)
    end
  end
end
