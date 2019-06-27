# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestDeliveryPutawayStatusCheck < MiniTestInteractors
    def test_initialize
      service = DeliveryPutawayStatusCheck.new(1, 7, 2)

      assert service.instance_variable_get('@repo').is_a?(ReplenishRepo)
      assert_equal 7, service.instance_variable_get('@quantity')
      assert_equal 1, service.instance_variable_get('@sku_id')
      assert_equal 2, service.instance_variable_get('@delivery_id')
    end

    def test_call
      mocked_method = MiniTest::Mock.new
      mocked_method.expect :call, true, []
      PackMaterialApp::ReplenishRepo.any_instance.stubs(:delivery_putaway_reaction_job).returns(mocked_method.call)
      service = DeliveryPutawayStatusCheck.new(1, 7, 2)
      assert service
      assert mocked_method.verify
    end
  end
end
