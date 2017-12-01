# frozen_string_literal: true

class PersonInteractor < BaseInteractor

  def create_person(params)
    res = validate_person_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    response = party_repo.create_person(res.to_h)
    if response[:id]
      @person_id = response[:id]
      success_response("Created person #{person_name}", person)
    else
      validation_failed_response(OpenStruct.new(messages: response[:error]))
    end
  end

  def update_person(id, params)
    @person_id = id
    res = validate_person_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    attrs = res.to_h
    role_ids = attrs.delete(:role_ids)
    roles_response = assign_person_roles(@person_id, role_ids)
    party_repo.update_person(id, attrs)
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
    party_id = party_repo.party_id_from_person(id)
    party_repo.assign_person_roles(id, role_ids)

    existing_ids = party_repo.party_role_ids(party_id)
    if existing_ids.eql?(role_ids.sort)
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
