# frozen_string_literal: true

class PersonInteractor < BaseInteractor

  def create_person(params)
    res = validate_person_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @person_id = party_repo.create_person(res.to_h)
    success_response("Created person #{person_name}", person)
  end

  def update_person(id, params)
    role_ids = params.delete(:role_ids)
    @person_id = id
    res = validate_person_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    roles_response = assign_person_roles(@person_id, role_ids)
    party_repo.update_person(id, res.to_h)
    if roles_response.success
      success_response("Updated person #{person_name}, #{roles_response.message}", person(false))
    else
      validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
    end
  end

  def delete_person(id)
    @person_id = id
    name = person_name
    party_repo.delete_person(id)
    success_response("Deleted person #{name}")
  end

  def assign_person_roles(id, role_ids)
    # TODO: Check if IDs are correct???
    party_repo.assign_person_roles(person_id, role_ids)

    if party_repo.existing_role_ids_for_party(person_id) == role_ids
      success_response('Roles assigned successfully')
    else
      validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
    end
  end

  private

  def party_repo
    @party_repo ||= PartyRepo.new
  end

  def person_name
    [person.title, person.first_name, person.surname].join(' ')
  end

  def person(cached = true)
    if cached
      @person ||= party_repo.find_person(@person_id)
    else
      @person = party_repo.find_person(@person_id)
    end
  end

  def validate_person_params(params)
    PersonSchema.call(params)
  end

end
