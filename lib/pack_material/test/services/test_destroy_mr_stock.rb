# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestRemoveMrStock < MiniTestInteractors
    def test_initialize
      service = RemoveMrStock.new(1, 2, 7, opts)

      assert service.instance_variable_get('@repo').is_a?(MrStockRepo)
      assert service.instance_variable_get('@transaction_repo').is_a?(TransactionsRepo)
      assert_equal 2, service.instance_variable_get('@location_id')
      assert_equal 7, service.instance_variable_get('@quantity')
      assert_equal 1, service.instance_variable_get('@sku_id')
      assert_equal opts, service.instance_variable_get('@opts')
      assert_equal 15, service.instance_variable_get('@business_process_id')
      assert_equal 16, service.instance_variable_get('@parent_transaction_id')
    end

    def test_location_does_not_exist_fail
      PackMaterialApp::MrStockRepo.any_instance.stubs(:exists?).returns(false)
      service = RemoveMrStock.call(1, 2, 7, opts)
      refute service.success
      assert_equal 'SKU location does not exist', service.message
    end

    def test_update_sku_location_quantity_fail
      failed_message = 'update_sku_location_quantity_fail'
      PackMaterialApp::MrStockRepo.any_instance.stubs(:exists?).returns(true)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:update_sku_location_quantity).returns(bad_response(message: failed_message))
      service = RemoveMrStock.call(1, 2, 7, opts)
      refute service.success
      assert_equal failed_message, service.message
    end

    def test_invalid_parent_transaction_fail
      failed_message = 'Invalid Parent Transaction Id'
      PackMaterialApp::MrStockRepo.any_instance.stubs(:exists?).returns(true)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:update_sku_location_quantity).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:activate_mr_inventory_transaction).returns(bad_response(message: failed_message))

      service = RemoveMrStock.call(1, 2, 7, opts)
      refute service.success
      assert_equal failed_message, service.message
    end

    def test_create_parent_transaction_fail
      options = opts
      options.delete(:parent_transaction_id)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:exists?).returns(true)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:update_sku_location_quantity).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:transaction_type_id_for).returns(1)

      assert_raises(Sequel::ForeignKeyConstraintViolation) { RemoveMrStock.call(1, 2, 7, options) }
    end

    def test_create_transaction_per_quantity
      PackMaterialApp::MrStockRepo.any_instance.stubs(:exists?).returns(true)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:sku_uom_id).returns(20)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:update_sku_location_quantity).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:transaction_type_id_for).returns(1)
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:create_mr_inventory_transaction_item).returns(15)

      service = RemoveMrStock.call(1, 2, 7, opts)
      assert service.success
      assert_equal 15, service.instance
      assert_equal 'ok', service.message
    end

    def test_sku_uom_id_called
      mocked_method = MiniTest::Mock.new
      mocked_method.expect :call, 20, []
      PackMaterialApp::MrStockRepo.any_instance.stubs(:exists?).returns(true)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:sku_uom_id).returns(mocked_method.call)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:update_sku_location_quantity).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:transaction_type_id_for).returns(1)
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:create_mr_inventory_transaction_item).returns(15)

      RemoveMrStock.call(1, 2, 7, opts)
      assert mocked_method.verify
    end

    def opts
      { is_adhoc: true, business_process_id: 15, user_name: 'User Name', parent_transaction_id: 16, ref_no: 'ref_no' }
    end
  end
end
