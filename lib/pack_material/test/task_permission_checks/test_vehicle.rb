# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestVehiclePermission < Minitest::Test
    include Crossbeams::Responses

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        vehicle_type_id: 1,
        vehicle_code: 'ABC'
      }
      PackMaterialApp::Vehicle.new(base_attrs.merge(attrs))
    end

    def test_create
      res = PackMaterialApp::TaskPermissionCheck::Vehicle.call(:create)
      assert res.success, 'Should always be able to create a vehicle'
    end

    def test_edit
      PackMaterialApp::TripsheetsRepo.any_instance.stubs(:find_vehicle).returns(entity)
      res = PackMaterialApp::TaskPermissionCheck::Vehicle.call(:edit, 1)
      assert res.success, 'Should be able to edit a vehicle'
    end

    def test_delete
      PackMaterialApp::TripsheetsRepo.any_instance.stubs(:find_vehicle).returns(entity)
      res = PackMaterialApp::TaskPermissionCheck::Vehicle.call(:delete, 1)
      assert res.success, 'Should be able to delete a vehicle'
    end
  end
end
