# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestMrBulkStockAdjustmentItemPermission < Minitest::Test
    include Crossbeams::Responses

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        mr_bulk_stock_adjustment_id: 1,
        mr_sku_location_id: 1,
        sku_number: 1,
        product_variant_number: 1,
        product_number: 1,
        mr_type_name: 'ABC',
        mr_sub_type_name: 'ABC',
        product_variant_code: 'ABC',
        product_code: 'ABC',
        location_code: 'ABC',
        inventory_uom_code: 'ABC',
        scan_to_location_code: 'ABC',
        system_quantity: 1.0,
        actual_quantity: 1.0,
        stock_take_complete: false,
        active: true
      }
      PackMaterialApp::MrBulkStockAdjustmentItem.new(base_attrs.merge(attrs))
    end

    def test_create
      res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustmentItem.call(:create)
      assert res.success, 'Should always be able to create a mr_bulk_stock_adjustment_item'
    end

    def test_edit
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment_item).returns(entity)
      res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustmentItem.call(:edit, 1)
      assert res.success, 'Should be able to edit a mr_bulk_stock_adjustment_item'

      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment_item).returns(entity(completed: true))
      res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustmentItem.call(:edit, 1)
      refute res.success, 'Should not be able to edit a completed mr_bulk_stock_adjustment_item'
    end

    def test_delete
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment_item).returns(entity)
      res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustmentItem.call(:delete, 1)
      assert res.success, 'Should be able to delete a mr_bulk_stock_adjustment_item'

      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment_item).returns(entity(completed: true))
      res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustmentItem.call(:delete, 1)
      refute res.success, 'Should not be able to delete a completed mr_bulk_stock_adjustment_item'
    end

    def test_complete
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment_item).returns(entity)
      res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustmentItem.call(:complete, 1)
      assert res.success, 'Should be able to complete a mr_bulk_stock_adjustment_item'

      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment_item).returns(entity(completed: true))
      res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustmentItem.call(:complete, 1)
      refute res.success, 'Should not be able to complete an already completed mr_bulk_stock_adjustment_item'
    end

    def test_approve
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment_item).returns(entity(completed: true, approved: false))
      res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustmentItem.call(:approve, 1)
      assert res.success, 'Should be able to approve a completed mr_bulk_stock_adjustment_item'

      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment_item).returns(entity)
      res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustmentItem.call(:approve, 1)
      refute res.success, 'Should not be able to approve a non-completed mr_bulk_stock_adjustment_item'

      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment_item).returns(entity(completed: true, approved: true))
      res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustmentItem.call(:approve, 1)
      refute res.success, 'Should not be able to approve an already approved mr_bulk_stock_adjustment_item'
    end

    def test_reopen
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment_item).returns(entity)
      res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustmentItem.call(:reopen, 1)
      refute res.success, 'Should not be able to reopen a mr_bulk_stock_adjustment_item that has not been approved'

      PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment_item).returns(entity(completed: true, approved: true))
      res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustmentItem.call(:reopen, 1)
      assert res.success, 'Should be able to reopen an approved mr_bulk_stock_adjustment_item'
    end
  end
end
