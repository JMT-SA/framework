# frozen_string_literal: true

module MasterfilesApp
  class CultivarInteractor < BaseInteractor # rubocop:disable Metrics/ClassLength
    def create_cultivar_group(params)
      res = validate_cultivar_group_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_cultivar_group(res)
      instance = cultivar_group(id)
      success_response("Created cultivar group #{instance.cultivar_group_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { cultivar_group_code: ['This cultivar group already exists'] }))
    end

    def update_cultivar_group(id, params)
      res = validate_cultivar_group_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_cultivar_group(id, res)
      instance = cultivar_group(id)
      success_response("Updated cultivar group #{instance.cultivar_group_code}", instance)
    end

    def delete_cultivar_group(id)
      name = cultivar_group(id).cultivar_group_code

      repo.transaction do
        cultivar_group = repo.find_cultivar_group(id)
        cultivar_group.cultivar_ids.each do |cultivar_id|
          repo.delete_cultivar(cultivar_id)
        end
        repo.delete_cultivar_group(id)
      end
      success_response("Deleted cultivar group #{name}")
    end

    def create_cultivar(params)
      res = validate_cultivar_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_cultivar(res)
      instance = cultivar(id)
      success_response("Created cultivar #{instance.cultivar_name}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { cultivar_name: ['This cultivar already exists'] }))
    end

    def update_cultivar(id, params)
      res = validate_cultivar_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_cultivar(id, res)
      instance = cultivar(id)
      success_response("Updated cultivar #{instance.cultivar_name}", instance)
    end

    def delete_cultivar(id)
      name = cultivar(id).cultivar_name
      repo.delete_cultivar(id)
      success_response("Deleted cultivar #{name}")
    end

    def create_marketing_variety(cultivar_id, params)
      res = validate_marketing_variety_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_marketing_variety(cultivar_id, res)
      instance = marketing_variety(id)
      success_response("Created marketing variety #{instance.marketing_variety_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { marketing_variety_code: ['This marketing variety already exists'] }))
    end

    def update_marketing_variety(id, params)
      res = validate_marketing_variety_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_marketing_variety(id, res)
      instance = marketing_variety(id)
      success_response("Updated marketing variety #{instance.marketing_variety_code}", instance)
    end

    def delete_marketing_variety(id)
      name = marketing_variety(id).marketing_variety_code
      repo.delete_marketing_variety(id)
      success_response("Deleted marketing variety #{name}")
    end

    def link_marketing_varieties(cultivar_id, marketing_variety_ids)
      repo.transaction do
        repo.link_marketing_varieties(cultivar_id, marketing_variety_ids)
      end

      existing_ids = repo.cultivar_marketing_variety_ids(cultivar_id)
      if existing_ids.eql?(marketing_variety_ids.sort)
        success_response('Marketing varieties linked successfully')
      else
        failed_response('Some marketing varieties were not linked')
      end
    end

    private

    def repo
      @repo ||= CultivarRepo.new
    end

    def cultivar_group(id)
      repo.find_cultivar_group(id)
    end

    def validate_cultivar_group_params(params)
      CultivarGroupSchema.call(params)
    end

    def cultivar(id)
      repo.find_cultivar(id)
    end

    def validate_cultivar_params(params)
      CultivarSchema.call(params)
    end

    def marketing_variety(id)
      repo.find_marketing_variety(id)
    end

    def validate_marketing_variety_params(params)
      MarketingVarietySchema.call(params)
    end
  end
end
