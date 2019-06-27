# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestBulkStockAdjustmentService < Minitest::Test
    def test_initialize
      object = OpenStruct.new(ref_no: 'test_ref')
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(object)
      service = PackMaterialApp::BulkStockAdjustmentService.new(1, 2, user_name: 'User Name')

      assert service.instance_variable_get('@this_repo').is_a?(PackMaterialApp::BulkStockAdjustmentRepo)
      assert service.instance_variable_get('@transaction_repo').is_a?(PackMaterialApp::TransactionsRepo)

      assert_equal 1, service.instance_variable_get('@bulk_stock_adjustment_id')
      assert_equal object, service.instance_variable_get('@bulk_stock_adj')
      assert_equal 'test_ref', service.instance_variable_get('@ref_no')
      assert_equal 2, service.instance_variable_get('@business_process_id')
      assert_equal ({ user_name: 'User Name' }), service.instance_variable_get('@opts')
    end

    def test_attrs
      object = OpenStruct.new(ref_no: 'test_ref')
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(object)
      service = PackMaterialApp::BulkStockAdjustmentService.new(1, 2, user_name: 'User Name')
      assert_equal ({ business_process_id: 2, ref_no: 'test_ref', user_name: 'User Name' }), service.send(:attrs)
    end

    def test_fail_on_not_found
      x = PackMaterialApp::BulkStockAdjustmentService.call(0, 2, user_name: 'User Name')
      assert_equal false, x.success
      assert_equal 'Bulk Stock Adjustment record does not exist', x.message
    end

    def test_create_transaction_id
      object = OpenStruct.new(ref_no: 'test_ref')
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(object)
      service = PackMaterialApp::BulkStockAdjustmentService.new(1, 2, user_name: 'User Name')

      create_id = 5
      PackMaterialApp::BulkStockAdjustmentRepo.any_instance.stubs(:transaction_id).returns(create_id)
      assert_equal create_id, service.send(:create_transaction_id, service.send(:attrs))
      PackMaterialApp::BulkStockAdjustmentRepo.any_instance.stubs(:transaction_id).returns(7)
      assert_equal create_id, service.send(:create_transaction_id, service.send(:attrs))
    end

    def test_destroy_transaction_id
      object = OpenStruct.new(ref_no: 'test_ref')
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(object)
      service = PackMaterialApp::BulkStockAdjustmentService.new(1, 2, user_name: 'User Name')

      destroy_id = 6
      PackMaterialApp::BulkStockAdjustmentRepo.any_instance.stubs(:transaction_id).returns(destroy_id)
      assert_equal destroy_id, service.send(:destroy_transaction_id, service.send(:attrs))
      PackMaterialApp::BulkStockAdjustmentRepo.any_instance.stubs(:transaction_id).returns(7)
      assert_equal destroy_id, service.send(:destroy_transaction_id, service.send(:attrs))
    end

    def test_call
      PackMaterialApp::RemoveMrStock.any_instance.stubs(:call).returns(OpenStruct.new(success: true, message: 'ok', instance: 1))
      PackMaterialApp::CreateMrStock.any_instance.stubs(:call).returns(OpenStruct.new(success: true, message: 'ok', instance: { transaction_item_ids: [{ transaction_item_id: 1 }] }))

      PackMaterialApp::BulkStockAdjustmentRepo.any_instance.stubs(:system_quantity).returns(5)
      PackMaterialApp::BulkStockAdjustmentRepo.any_instance.stubs(:separate_items).returns(
        destroy_stock_items: [{ id: 1, actual_quantity: 4, mr_sku_id: 1, location_id: 1 }],
        create_stock_items: [{ id: 1, actual_quantity: 25, mr_sku_id: 1, location_id: 1 }]
      )
      PackMaterialApp::BulkStockAdjustmentRepo.any_instance.stubs(:transaction_id).returns(7)
      PackMaterialApp::BulkStockAdjustmentRepo.any_instance.stubs(:update_transaction_ids).returns(true)

      object = OpenStruct.new(ref_no: 'test_ref')
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(object)

      x = PackMaterialApp::BulkStockAdjustmentService.call(1, 2, user_name: 'User Name')
      assert x.success

      PackMaterialApp::RemoveMrStock.any_instance.stubs(:call).returns(
        OpenStruct.new(success: false, message: 'failed', instance: 1)
      )
      x = PackMaterialApp::BulkStockAdjustmentService.call(1, 2, user_name: 'User Name')
      refute x.success
      assert_equal 'Bulk Stock Adjustment Item 1: Attempt to destroy stock failed - failed', x.message

      PackMaterialApp::RemoveMrStock.any_instance.stubs(:call).returns(
        OpenStruct.new(success: true, message: 'ok', instance: 1)
      )
      PackMaterialApp::CreateMrStock.any_instance.stubs(:call).returns(
        OpenStruct.new(success: false, message: 'failed', instance: { transaction_item_ids: [{ transaction_item_id: 1 }] })
      )
      x = PackMaterialApp::BulkStockAdjustmentService.call(1, 2, user_name: 'User Name')
      refute x.success
      assert_equal 'Bulk Stock Adjustment Item 1: Attempt to create stock failed - failed', x.message
    end
  end
end
