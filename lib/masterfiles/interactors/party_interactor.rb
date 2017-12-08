# frozen_string_literal: true

class PartyInteractor < BaseInteractor
  def link_addresses(id, address_ids)
    DB.transaction do
      party_repo.link_addresses(id, address_ids)
    end

    party = party_repo.find_party(id)
    existing_ids = party_repo.party_address_ids(id)
    if existing_ids.eql?(address_ids.sort)
      success_response('Addresses linked successfully', party)
    else
      failed_response('Some addresses were not linked', party)
    end
  end

  def link_contact_methods(id, contact_method_ids)
    DB.transaction do
      party_repo.link_contact_methods(id, contact_method_ids)
    end

    party = party_repo.find_party(id)
    existing_ids = party_repo.party_contact_method_ids(id)
    if existing_ids.eql?(contact_method_ids.sort)
      success_response('Contact methods linked successfully', party)
    else
      failed_response('Some contact methods were not linked', party)
    end
  end

  private

  def party_repo
    @party_repo ||= PartyRepo.new
  end
end
