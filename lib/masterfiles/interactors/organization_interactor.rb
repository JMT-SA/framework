# frozen_string_literal: true

class OrganizationInteractor < BaseInteractor

  def create_organization(params)
    res = validate_organization_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_party
    @id = organization_repo.create(res.to_h)

    success_response("Created organization #{organization.short_description}",
                     organization)
  end

  def update_organization(id, params)
    # party = PartyRepo.find(id)
    @id = id #party.organization_id || party.person_id
    res = validate_organization_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_party... etc.
    organization_repo.update(id, res.to_h)
    success_response("Updated organization #{organization.short_description}",
                     organization(false))
  end

  def delete_organization(id)
    @id = id
    name = organization.short_description
    organization_repo.delete_with_all(id)
    success_response("Deleted organization #{name}")
  end

  def assign_roles(id, params)
    if params[:roles]
      organization_repo.assign_roles(id, params[:roles].map(&:to_i))
      party_ex = organization_repo.find_with_roles(id)
      success_response("Updated roles on party #{party_ex.short_description}",
                       party_ex)
    else
      validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
    end
  end

  private
  def organization_repo
    @organization_repo ||= OrganizationRepo.new
  end

  def organization(cached = true)
    if cached
      @organization ||= organization_repo.find(@id)
    else
      @organization = organization_repo.find(@id)
    end
  end

  def validate_organization_params(params)
    OrganizationSchema.call(params)
  end

end
