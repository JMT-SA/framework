# # frozen_string_literal: true
#
# require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')
#
# module PackMaterialApp
#   class TestMrBulkStockAdjustmentPermission < Minitest::Test
#     include Crossbeams::Responses
#
#     def entity(attrs = {})
#       base_attrs = {
#         id: 1,
#         stock_adjustment_number: 1,
#         is_stock_take: false,
#         completed: false,
#         approved: false,
#         active: true
#       }
#       PackMaterialApp::MrBulkStockAdjustment.new(base_attrs.merge(attrs))
#     end
#
#     def test_create
#       res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment.call(:create)
#       assert res.success, 'Should always be able to create a mr_bulk_stock_adjustment'
#     end
#
#     def test_edit
#       PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(entity)
#       res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment.call(:edit, 1)
#       assert res.success, 'Should be able to edit a mr_bulk_stock_adjustment'
#
#       PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(entity(completed: true))
#       res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment.call(:edit, 1)
#       refute res.success, 'Should not be able to edit a completed mr_bulk_stock_adjustment'
#     end
#
#     def test_delete
#       PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(entity)
#       res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment.call(:delete, 1)
#       assert res.success, 'Should be able to delete a mr_bulk_stock_adjustment'
#
#       PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(entity(completed: true))
#       res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment.call(:delete, 1)
#       refute res.success, 'Should not be able to delete a completed mr_bulk_stock_adjustment'
#     end
#
#     def test_complete
#       PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(entity)
#       res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment.call(:complete, 1)
#       assert res.success, 'Should be able to complete a mr_bulk_stock_adjustment'
#
#       PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(entity(completed: true))
#       res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment.call(:complete, 1)
#       refute res.success, 'Should not be able to complete an already completed mr_bulk_stock_adjustment'
#     end
#
#     def test_approve
#       PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(entity(completed: true, approved: false))
#       res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment.call(:approve, 1)
#       assert res.success, 'Should be able to approve a completed mr_bulk_stock_adjustment'
#
#       PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(entity)
#       res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment.call(:approve, 1)
#       refute res.success, 'Should not be able to approve a non-completed mr_bulk_stock_adjustment'
#
#       PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(entity(completed: true, approved: true))
#       res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment.call(:approve, 1)
#       refute res.success, 'Should not be able to approve an already approved mr_bulk_stock_adjustment'
#     end
#
#     def test_reopen
#       PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(entity)
#       res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment.call(:reopen, 1)
#       refute res.success, 'Should not be able to reopen a mr_bulk_stock_adjustment that has not been approved'
#
#       PackMaterialApp::TransactionsRepo.any_instance.stubs(:find_mr_bulk_stock_adjustment).returns(entity(completed: true, approved: true))
#       res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment.call(:reopen, 1)
#       assert res.success, 'Should be able to reopen an approved mr_bulk_stock_adjustment'
#     end
#   end
# end
