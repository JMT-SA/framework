# frozen_string_literal: true

module MasterfilesApp
  class ContactMethodInteractor < BaseInteractor
    def create_contact_method(params)
      res = validate_contact_method_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @contact_method_id = party_repo.create_contact_method(res.to_h)
      success_response("Created contact method #{contact_method.contact_method_code}",
                       contact_method)
    end

    def update_contact_method(id, params)
      @contact_method_id = id
      res = validate_contact_method_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      party_repo.update_contact_method(id, res.to_h)
      success_response("Updated contact method #{contact_method.contact_method_code}",
                       contact_method(false))
    end

    def delete_contact_method(id)
      @contact_method_id = id
      name = contact_method.contact_method_code
      party_repo.delete_contact_method(id)
      success_response("Deleted contact method #{name}")
    end

    private

    def party_repo
      @party_repo ||= PartyRepo.new
    end

    def contact_method(cached = true)
      if cached
        @contact_method ||= party_repo.find_contact_method(@contact_method_id)
      else
        @contact_method = party_repo.find_contact_method(@contact_method_id)
      end
    end

    def validate_contact_method_params(params)
      ContactMethodSchema.call(params)
    end
  end
end
