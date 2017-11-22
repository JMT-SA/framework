# frozen_string_literal: true

class AddressInteractor < BaseInteractor

  def create_address(params)
    res = validate_address_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = address_repo.create(res.to_h)
    success_response("Created address #{address.address_line_1}",
                     address)
  end

  def update_address(id, params)
    @id = id
    res = validate_address_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    address_repo.update(id, res.to_h)
    success_response("Updated address #{address.address_line_1}",
                     address(false))
  end

  def delete_address(id)
    @id = id
    name = address.address_line_1
    address_repo.delete(id)
    success_response("Deleted address #{name}")
  end

  private
  def address_repo
    @address_repo ||= AddressRepo.new
  end

  def address(cached = true)
    if cached
      @address ||= address_repo.find(@id)
    else
      @address = address_repo.find(@id)
    end
  end

  def validate_address_params(params)
    AddressSchema.call(params)
  end

end
