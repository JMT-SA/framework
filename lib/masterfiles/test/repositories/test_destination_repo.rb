# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestDestinationRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_destination_regions
      assert_respond_to repo, :for_select_destination_countries
      assert_respond_to repo, :for_select_destination_cities
    end

    def test_crud_calls
      assert_respond_to repo, :find_region
      assert_respond_to repo, :create_region
      assert_respond_to repo, :update_region
      assert_respond_to repo, :delete_region

      assert_respond_to repo, :find_country
      assert_respond_to repo, :create_country
      assert_respond_to repo, :update_country
      assert_respond_to repo, :delete_country

      assert_respond_to repo, :find_city
      assert_respond_to repo, :create_city
      assert_respond_to repo, :update_city
      assert_respond_to repo, :delete_city
    end

    private

    def repo
      DestinationRepo.new
    end
  end
end
