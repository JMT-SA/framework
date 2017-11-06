# frozen_string_literal: true

class PersonInteractor < BaseInteractor
  def person_repo
    @person_repo ||= PersonRepo.new
  end

  def person_name
    [person.title, person.first_name, person.surname].join(' ')
  end

  def person(cached = true)
    if cached
      @person ||= person_repo.find(@id)#find_relative_party
    else
      @person = person_repo.find(@id)#find_relative_party
    end
  end

  def validate_person_params(params)
    PersonSchema.call(params)
  end

  # --| actions
  def create_person(params)
    res = validate_person_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_party
    @id = person_repo.create(res.to_h)
    success_response("Created person #{person_name}",
                     person)
  end

  def update_person(id, params)
    # party = PartyRepo.find(id)
    @id = id #party.person_id || party.person_id
    res = validate_person_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_party... etc.
    person_repo.update(id, res.to_h)
    success_response("Updated person #{person_name}",
                     person(false))
  end

  def delete_person(id)
    @id = id
    name = person.name
    person_repo.delete_with_roles(id)
    success_response("Deleted person #{name}")
  end

  def assign_roles(id, params)
    if params[:roles]
      person_repo.assign_roles(id, params[:roles].map(&:to_i))
      party_ex = person_repo.find_with_roles(id)
      success_response("Updated roles on party #{[party_ex.title, party_ex.first_name, party_ex.surname].join(' ')}",
                       party_ex)
    else
      validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
    end
  end


end
