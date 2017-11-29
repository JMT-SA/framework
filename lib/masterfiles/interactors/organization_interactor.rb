# frozen_string_literal: true

class OrganizationInteractor < BaseInteractor
  def create_organization(params)
    role_ids = params.delete(:role_ids)
    res = validate_organization_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @organization_id = party_repo.create_organization(res.to_h)
    roles_response = assign_organization_roles(@organization_id, role_ids)
    if roles_response.success
      success_response("Created organization #{organization.short_description}, #{roles_response.message}", organization)
    else
      validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
    end
  end

  def update_organization(id, params)
    role_ids = params.delete(:role_ids)
    @organization_id = id
    res = validate_organization_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    party_repo.update_organization(id, res.to_h)
    roles_response = assign_organization_roles(@organization_id, role_ids)
    if roles_response.success
      success_response("Updated organization #{organization.short_description}, #{roles_response.message}", organization(false))
    else
      validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
    end
  end

  def delete_organization(id)
    @organization_id = id
    name = organization.short_description
    party_repo.delete_organization(id)
    success_response("Deleted organization #{name}")
  end

  def assign_organization_roles(id, role_ids)
    organization = party_repo.find_organization(id)
    party_id = organization.party_id
    party_repo.assign_organization_roles(id, role_ids)

    existing_ids = party_repo.existing_role_ids_for_party(party_id)
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

  def organization(cached = true)
    if cached
      @organization ||= party_repo.find_organization(@organization_id)
    else
      @organization = party_repo.find_organization(@organization_id)
    end
  end

  def validate_organization_params(params)
    OrganizationSchema.call(params)
  end
end
