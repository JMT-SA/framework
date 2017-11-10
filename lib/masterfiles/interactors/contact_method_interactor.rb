# frozen_string_literal: true

class ContactMethodInteractor < BaseInteractor

  def create_contact_method(params)
    res = validate_contact_method_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_contact_method... etc.
    @id = contact_method_repo.create(res.to_h)
    success_response("Created contact method #{contact_method.contact_method_code}",
                     contact_method)
  end

  def update_contact_method(id, params)
    @id = id
    res = validate_contact_method_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_contact_method... etc.
    contact_method_repo.update(id, res.to_h)
    success_response("Updated contact method #{contact_method.contact_method_code}",
                     contact_method(false))
  end

  def delete_contact_method(id)
    @id = id
    name = contact_method.contact_method_code
    contact_method_repo.delete(id)
    success_response("Deleted contact method #{name}")
  end

  private
  def contact_method_repo
    @contact_method_repo ||= ContactMethodRepo.new
  end

  def contact_method(cached = true)
    if cached
      @contact_method ||= contact_method_repo.find(@id)
    else
      @contact_method = contact_method_repo.find(@id)
    end
  end

  def validate_contact_method_params(params)
    ContactMethodSchema.call(params)
  end

end
