# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestCreateDeliverySKUS < Minitest::Test
    def test_initialize
      service = PackMaterialApp::CreateDeliverySKUS.new(1, 'User Name')

      assert_equal 1, service.instance_variable_get('@id')
      assert_equal 'User Name', service.instance_variable_get('@user_name')
      assert service.instance_variable_get('@repo').is_a?(PackMaterialApp::MrStockRepo)
    end

    def test_call
      object = OpenStruct.new(receipt_location_id: 15)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:create_skus_for_delivery).returns([1, 2, 3])
      PackMaterialApp::MrStockRepo.any_instance.stubs(:log_status).returns(true)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:resolve_business_process_id).returns(5)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:find_mr_delivery).returns(object)
      PackMaterialApp::CreateMrStock.any_instance.stubs(:call).returns('Stubbed call to CreateMrStock')
      service = PackMaterialApp::CreateDeliverySKUS.call(1, 'User Name')

      assert_equal 'Stubbed call to CreateMrStock', service
    end

    def test_fail_on_not_found
      x = PackMaterialApp::CreateDeliverySKUS.call(1, 'User Name')
      assert_equal false, x.success
      assert_equal 'Delivery record does not exist', x.message
    end
  end
end