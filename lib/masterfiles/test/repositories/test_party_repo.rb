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
    end

    private

    def repo
      PartyRepo.new
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
