# frozen_string_literal: true

class PartyInteractor < BaseInteractor

  def link_addresses(id, params)
    repo = PartyRepo.new
    address_ids = CommonHelpers.multiselect_grid_choices(params)
    repo.link_addresses(id, address_ids)

    if (repo.existing_address_ids_for_party(id) == address_ids)
      success_response('Addresses linked successfully')
    else
      failed_response('Some addresses were not linked')
    end
  end

  def link_contact_methods(id, params)
    repo = PartyRepo.new
    contact_method_ids = CommonHelpers.multiselect_grid_choices(params)
    repo.link_contact_methods(id, contact_method_ids)

    if (repo.existing_contact_method_ids_for_party(id) == address_ids)
      success_response('Contact methods linked successfully')
    else
      failed_response('Some contact methods were not linked')
    end
  end

end
