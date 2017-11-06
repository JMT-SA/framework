# frozen_string_literal: true

class OrganizationInteractor < BaseInteractor
  # Implementing for Organization only for now

  # def party_repo
  #   @party_repo ||= PartyRepo.new
  # end

  def organization_repo
    @organization_repo ||= OrganizationRepo.new
  end

  # def person_repo
  #   @person_repo ||= PersonRepo.new
  # end

  def organization(cached = true)
    if cached
      @organization ||= organization_repo.find(@id)#find_relative_party
    else
      @organization = organization_repo.find(@id)#find_relative_party
    end
  end
  #
  #
  # def find_relative_party
  #   repo = party_repo.find(@id)
  #   if (repo.party_type == 'O')
  #     party = organization_repo.find(@id)
  #   else
  #     party = person_repo.find(@id)
  #   end
  #   party
  # end

  # def validate_party_params(params)
  #   PartySchema.call(params)
  # end

  def validate_organization_params(params)
    OrganizationSchema.call(params)
  end
  #
  # def validate_person_params(params)
  #   PersonSchema.call(params)
  # end



  # I want to use the party ID instead of the person and organization ids so that they are sequential
  # def create_person_party
  #
  # end
  #
  # def update_person_party
  #
  # end

  # def delete_person_party
  #
  # end

  def get_parties

  end

  def get_organization

  end

  def get_organizations

  end

  def get_person

  end

  def get_people

  end

  # If you can create a party you can see these
  def get_roles

  end

  def get_contact_methods

  end

  def get_address_types

  end

  # Need to have certain permissions
  def create_role

  end

  def create_contact_method

  end

  def create_address_type

  end




  # --| actions
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
    organization_repo.delete_with_roles(id)
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


end
