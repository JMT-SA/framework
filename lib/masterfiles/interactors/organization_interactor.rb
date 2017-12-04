# frozen_string_literal: true

class OrganizationInteractor < BaseInteractor
  def create_organization(params)
    res = validate_organization_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    response = party_repo.create_organization(res.to_h)
    if response[:id]
      @organization_id = response[:id]
      success_response("Created organization #{organization.party_name}", organization)
    else
      validation_failed_response(OpenStruct.new(messages: response[:error]))
    end
  end

  def update_organization(id, params)
    @organization_id = id
    res = validate_organization_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    attrs = res.to_h
    role_ids = attrs.delete(:role_ids)
    roles_response = assign_organization_roles(@organization_id, role_ids)
    party_repo.update_organization(id, attrs)
    if roles_response.success
      success_response("Updated organization #{organization.party_name}, #{roles_response.message}", organization(false))
    else
      validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
    end
  end

  def delete_organization(id)
    @organization_id = id
    name = organization.party_name
    response = party_repo.delete_organization(id)
    if response[:success]
      success_response("Deleted organization #{name}")
    else
      validation_failed_response(OpenStruct.new(messages: response[:error]))
    end
  end

  def assign_organization_roles(id, role_ids)
    party_id = party_repo.party_id_from_organization(id)
    party_repo.assign_organization_roles(id, role_ids)

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
