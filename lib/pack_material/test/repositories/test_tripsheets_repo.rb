# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestTripsheetsRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_vehicle_types
    end

    def test_crud_calls
      test_crud_calls_for :vehicle_types, name: :vehicle_type, wrapper: VehicleType
    end

    private

    def repo
      TripsheetsRepo.new
    end
  end
end
