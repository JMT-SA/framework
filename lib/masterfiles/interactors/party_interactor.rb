# frozen_string_literal: true

class PartyInteractor < BaseInteractor
  def link_addresses(id, address_ids)
    DB.transaction do
      party_repo.link_addresses(id, address_ids)
    end
    success_response('Addresses linked successfully')
  end

  def link_contact_methods(id, contact_method_ids)
    DB.transaction do
      party_repo.link_contact_methods(id, contact_method_ids.uniq)
    end
    success_response('Contact methods linked successfully')
  end

  private

  def party_repo
    @party_repo ||= PartyRepo.new
  end
end
