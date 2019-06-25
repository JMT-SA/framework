# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

module MasterfilesApp
  class CultivarInteractor < BaseInteractor
    def create_cultivar_group(params)
      res = validate_cultivar_group_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      @cultivar_group_id = repo.create_cultivar_group(res)
      success_response("Created cultivar group #{cultivar_group.cultivar_group_code}", cultivar_group)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { cultivar_group_code: ['This cultivar group already exists'] }))
    end

    def update_cultivar_group(id, params)
      @cultivar_group_id = id
      res = validate_cultivar_group_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.update_cultivar_group(id, res)
      success_response("Updated cultivar group #{cultivar_group.cultivar_group_code}", cultivar_group(false))
    end

    def delete_cultivar_group(id)
      @cultivar_group_id = id
      name = cultivar_group.cultivar_group_code

      cultivar_group = repo.find_cultivar_group(id)
      cultivar_group.cultivar_ids.each do |cultivar_id|
        repo.delete_cultivar(cultivar_id)
      end
      repo.delete_cultivar_group(id)
      success_response("Deleted cultivar group #{name}")
    end

    def create_cultivar(params)
      res = validate_cultivar_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      @cultivar_id = repo.create_cultivar(res)
      success_response("Created cultivar #{cultivar.cultivar_name}", cultivar)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { cultivar_name: ['This cultivar already exists'] }))
    end

    def update_cultivar(id, params)
      @cultivar_id = id
      res = validate_cultivar_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.update_cultivar(id, res)
      # instance = cultivar(id)
      # comm_repo = MasterfilesApp::CommodityRepo.new
      # commodity_code = comm_repo.find_commodity(instance.commodity_id)&.code
      # success_response("Updated cultivar #{cultivar.cultivar_name}", instance.to_h.merge(commodity_code: commodity_code))
      success_response("Updated cultivar #{cultivar.cultivar_name}", cultivar(false))
    end

    def delete_cultivar(id)
      @cultivar_id = id
      name = cultivar.cultivar_name
      repo.delete_cultivar(id)
      success_response("Deleted cultivar #{name}")
    end

    def create_marketing_variety(cultivar_id, params)
      res = validate_marketing_variety_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      @marketing_variety_id = repo.create_marketing_variety(cultivar_id, res)
      success_response("Created marketing variety #{marketing_variety.marketing_variety_code}", marketing_variety)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { marketing_variety_code: ['This marketing variety already exists'] }))
    end

    def update_marketing_variety(id, params)
      @marketing_variety_id = id
      res = validate_marketing_variety_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.update_marketing_variety(id, res)
      success_response("Updated marketing variety #{marketing_variety.marketing_variety_code}", marketing_variety(false))
    end

    def delete_marketing_variety(id)
      @marketing_variety_id = id
      name = marketing_variety.marketing_variety_code
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

    def cultivar_group(cached = true)
      if cached
        @cultivar_group ||= repo.find_cultivar_group(@cultivar_group_id)
      else
        @cultivar_group = repo.find_cultivar_group(@cultivar_group_id)
      end
    end

    def validate_cultivar_group_params(params)
      CultivarGroupSchema.call(params)
    end

    def cultivar(cached = true)
      if cached
        @cultivar ||= repo.find_cultivar(@cultivar_id)
      else
        @cultivar = repo.find_cultivar(@cultivar_id)
      end
    end

    def validate_cultivar_params(params)
      CultivarSchema.call(params)
    end

    def marketing_variety(cached = true)
      if cached
        @marketing_variety ||= repo.find_marketing_variety(@marketing_variety_id)
      else
        @marketing_variety = repo.find_marketing_variety(@marketing_variety_id)
      end
    end

    def validate_marketing_variety_params(params)
      MarketingVarietySchema.call(params)
    end
  end
end
# rubocop:enable Metrics/ClassLength
