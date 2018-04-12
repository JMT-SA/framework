# frozen_string_literal: true

require File.join(File.expand_path('../../../../../test', __FILE__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class TestPartyRepo < Minitest::Test
    def test_for_selects
      assert_respond_to repo, :for_select_organizations
      assert_respond_to repo, :for_select_people
    end

    def test_crud_calls
      assert_respond_to repo, :find_organization
      assert_respond_to repo, :create_organization
      assert_respond_to repo, :update_organization
      assert_respond_to repo, :delete_organization

      assert_respond_to repo, :find_person
      assert_respond_to repo, :create_person
      assert_respond_to repo, :update_person
      assert_respond_to repo, :delete_person

      assert_respond_to repo, :find_address
      assert_respond_to repo, :create_address
      assert_respond_to repo, :update_address
      assert_respond_to repo, :delete_address
    end

    def test_the_following_methods
      skip 'for_select_contact_method_types'
      skip 'for_select_address_types'
      skip 'find_party(id)'
      skip 'create_organization(attrs)'
      skip 'find_organization(id)'
      skip 'delete_organization(id)'
      skip 'create_person(attrs)'
      skip 'find_person(id)'
      skip 'delete_person(id)'
      skip 'create_contact_method(attrs)'
      skip 'find_contact_method(id)'
      skip 'update_contact_method(id, attrs)'
      skip 'delete_contact_method(id)'
      skip 'find_address(id)'
      skip 'link_addresses(party_id, address_ids)'
      skip 'link_contact_methods(party_id, contact_method_ids)'
      skip 'addresses_for_party(party_id: nil, organization_id: nil, person_id: nil)'
      skip 'contact_methods_for_party(party_id: nil, organization_id: nil, person_id: nil)'
      skip 'party_id_from_organization(id)'
      skip 'party_id_from_person(id)'
      skip 'party_address_ids(party_id)'
      skip 'party_contact_method_ids(party_id)'
      skip 'party_role_ids(party_id)'
      skip "assign_roles(id, role_ids, type = 'organization')"
      skip 'add_party_name(hash)'
      skip 'add_dependent_ids(hash)'
      skip 'delete_party_dependents(party_id)'
    end

    private

    def repo
      PartyRepo.new
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
