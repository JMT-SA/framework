# frozen_string_literal: true

class PersonInteractor < BaseInteractor

  def create_person(params)
    res = validate_person_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = person_repo.create(res.to_h)
    success_response("Created person #{person_name}", person)
  end

  def update_person(id, params)
    @id = id
    res = validate_person_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    person_repo.update(id, res.to_h)
    success_response("Updated person #{person_name}", person(false))
  end

  def delete_person(id)
    @id = id
    name = person_name
    person_repo.delete_with_all(id)
    success_response("Deleted person #{name}")
  end

  def assign_roles(id, params)
    if params[:roles]
      person_repo.assign_roles(id, params[:roles].map(&:to_i))
      party_ex = person_repo.find_with_roles(id)
      success_response("Updated roles on party #{[party_ex.title, party_ex.first_name, party_ex.surname].join(' ')}", party_ex)
    else
      validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
    end
  end

  private
  def person_repo
    @person_repo ||= PersonRepo.new
  end

  def person_name
    [person.title, person.first_name, person.surname].join(' ')
  end

  def person(cached = true)
    if cached
      @person ||= person_repo.find(@id)
    else
      @person = person_repo.find(@id)
    end
  end

  def validate_person_params(params)
    PersonSchema.call(params)
  end


end
