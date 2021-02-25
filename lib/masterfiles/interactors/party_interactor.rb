# frozen_string_literal: true

module MasterfilesApp
  class PartyInteractor < BaseInteractor
    def link_addresses(id, address_ids)
      repo.transaction do
        repo.link_addresses(id, address_ids)
      end
      success_response('Addresses linked successfully')
    rescue Sequel::UniqueConstraintViolation => e
      unique_link_addresses_failed_response(e.message)
    end

    def link_contact_methods(id, contact_method_ids)
      repo.transaction do
        repo.link_contact_methods(id, contact_method_ids.uniq)
      end
      success_response('Contact methods linked successfully')
    end

    private

    def repo
      @repo ||= PartyRepo.new
    end

    def unique_link_addresses_failed_response(message) # rubocop:disable Metrics/AbcSize
      ar = message[/(Key \(.+\))/].split('(')
      hash = Hash[ar[1].split(')').first.split(', ').map(&:to_sym).zip(ar[2].split(')').first.split(', ').map(&:to_i))]
      party_name = repo.fn_party_name(hash[:party_id])
      address_type = repo.get(:address_types, hash[:address_type_id], :address_type)
      failed_response "#{party_name} can't have multiple #{address_type}es."
    end
  end
end
