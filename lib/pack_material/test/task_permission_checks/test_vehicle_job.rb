# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestVehicleJobPermission < Minitest::Test
    include Crossbeams::Responses

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        business_process_id: 1,
        vehicle_id: 1,
        departure_location_id: 1,
        tripsheet_number: 1,
        planned_location_id: 1,
        virtual_location_id: 1,
        when_loaded: '2010-01-01 12:00',
        when_offloaded: '2010-01-01 12:00',
        loaded: false,
        offloaded: false,
        load_transaction_id: 1,
        offload_transaction_id: 1,
        arrival_confirmed: false
      }
      PackMaterialApp::VehicleJob.new(base_attrs.merge(attrs))
    end

    def test_create
      res = PackMaterialApp::TaskPermissionCheck::VehicleJob.call(:create)
      assert res.success, 'Should always be able to create a vehicle_job'
    end

    def test_edit
      PackMaterialApp::TripsheetsRepo.any_instance.stubs(:find_vehicle_job).returns(entity)
      res = PackMaterialApp::TaskPermissionCheck::VehicleJob.call(:edit, 1)
      assert res.success, 'Should be able to edit a vehicle_job'

      # PackMaterialApp::TripsheetsRepo.any_instance.stubs(:find_vehicle_job).returns(entity(completed: true))
      # res = PackMaterialApp::TaskPermissionCheck::VehicleJob.call(:edit, 1)
      # refute res.success, 'Should not be able to edit a completed vehicle_job'
    end

    def test_delete
      PackMaterialApp::TripsheetsRepo.any_instance.stubs(:find_vehicle_job).returns(entity)
      res = PackMaterialApp::TaskPermissionCheck::VehicleJob.call(:delete, 1)
      assert res.success, 'Should be able to delete a vehicle_job'

      # PackMaterialApp::TripsheetsRepo.any_instance.stubs(:find_vehicle_job).returns(entity(completed: true))
      # res = PackMaterialApp::TaskPermissionCheck::VehicleJob.call(:delete, 1)
      # refute res.success, 'Should not be able to delete a completed vehicle_job'
    end

    # def test_complete
    #   PackMaterialApp::TripsheetsRepo.any_instance.stubs(:find_vehicle_job).returns(entity)
    #   res = PackMaterialApp::TaskPermissionCheck::VehicleJob.call(:complete, 1)
    #   assert res.success, 'Should be able to complete a vehicle_job'

    #   PackMaterialApp::TripsheetsRepo.any_instance.stubs(:find_vehicle_job).returns(entity(completed: true))
    #   res = PackMaterialApp::TaskPermissionCheck::VehicleJob.call(:complete, 1)
    #   refute res.success, 'Should not be able to complete an already completed vehicle_job'
    # end

    # def test_approve
    #   PackMaterialApp::TripsheetsRepo.any_instance.stubs(:find_vehicle_job).returns(entity(completed: true, approved: false))
    #   res = PackMaterialApp::TaskPermissionCheck::VehicleJob.call(:approve, 1)
    #   assert res.success, 'Should be able to approve a completed vehicle_job'

    #   PackMaterialApp::TripsheetsRepo.any_instance.stubs(:find_vehicle_job).returns(entity)
    #   res = PackMaterialApp::TaskPermissionCheck::VehicleJob.call(:approve, 1)
    #   refute res.success, 'Should not be able to approve a non-completed vehicle_job'

    #   PackMaterialApp::TripsheetsRepo.any_instance.stubs(:find_vehicle_job).returns(entity(completed: true, approved: true))
    #   res = PackMaterialApp::TaskPermissionCheck::VehicleJob.call(:approve, 1)
    #   refute res.success, 'Should not be able to approve an already approved vehicle_job'
    # end

    # def test_reopen
    #   PackMaterialApp::TripsheetsRepo.any_instance.stubs(:find_vehicle_job).returns(entity)
    #   res = PackMaterialApp::TaskPermissionCheck::VehicleJob.call(:reopen, 1)
    #   refute res.success, 'Should not be able to reopen a vehicle_job that has not been approved'

    #   PackMaterialApp::TripsheetsRepo.any_instance.stubs(:find_vehicle_job).returns(entity(completed: true, approved: true))
    #   res = PackMaterialApp::TaskPermissionCheck::VehicleJob.call(:reopen, 1)
    #   assert res.success, 'Should be able to reopen an approved vehicle_job'
    # end
  end
end
