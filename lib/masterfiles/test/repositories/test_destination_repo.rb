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
      test_crud_calls_for :destination_regions, name: :region, wrapper: Region
      test_crud_calls_for :destination_countries, name: :country, wrapper: Country
      test_crud_calls_for :destination_cities, name: :city, wrapper: City
    end

    private

    def repo
      DestinationRepo.new
    end
  end
end
