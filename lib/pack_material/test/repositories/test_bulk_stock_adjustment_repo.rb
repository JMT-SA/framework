require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestBulkStockAdjustmentRepo < MiniTestWithHooks
    include ConfigFactory
    include MasterfilesApp::PartyFactory
    include PmProductFactory

    def test_transaction_repo
      x = repo.send(:transaction_repo)
      assert x.is_a?(PackMaterialApp::TransactionsRepo)
    end

    def test_mr_stock_repo
      x = repo.send(:mr_stock_repo)
      assert x.is_a?(PackMaterialApp::MrStockRepo)
    end

    def test_system_quantity
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:system_quantity).returns(5.0)
      assert_equal 5.0, repo.system_quantity(1, 2)
    end

    def test_find_business_process_id
      id = @fixed_table_set[:processes][:bulk_stock_adjustments_process_id]
      assert_equal id, repo.find_business_process_id
    end

    def test_transaction_id
      transaction_id = repo.transaction_id('create',
                                           business_process_id: @fixed_table_set[:processes][:bulk_stock_adjustments_process_id],
                                           ref_no: 'ref_no',
                                           user_name: 'user_name')
      assert transaction_id
    end

    def test_update_item_transaction_id
      transaction_item = create_transaction_item
      bsa_item = create_bulk_stock_adjustment_item

      repo.update_item_transaction_id(bsa_item[:id], transaction_item[:id])

      assert transaction_item[:id], DB[:mr_bulk_stock_adjustment_items].where(id: bsa_item[:id]).get(:mr_inventory_transaction_item_id)
    end

    def test_update_transaction_ids
      create_transaction_id = create_transaction[:id]
      destroy_transaction_id = create_transaction[:id]
      bsa = create_bulk_stock_adjustment

      repo.update_transaction_ids(bsa[:id], create_transaction_id, destroy_transaction_id)

      assert_equal create_transaction_id, DB[:mr_bulk_stock_adjustments].where(id: bsa[:id]).get(:create_transaction_id)
      assert_equal destroy_transaction_id, DB[:mr_bulk_stock_adjustments].where(id: bsa[:id]).get(:destroy_transaction_id)
    end

    def test_separate_items
      bsa_item1 = create_bulk_stock_adjustment_item(actual_quantity: 20)
      bsa_item2 = create_bulk_stock_adjustment_item(mr_bulk_stock_adjustment_id: bsa_item1[:parent_id], actual_quantity: 20)
      bsa_item3 = create_bulk_stock_adjustment_item(mr_bulk_stock_adjustment_id: bsa_item1[:parent_id], actual_quantity: 30)
      bsa_item4 = create_bulk_stock_adjustment_item(mr_bulk_stock_adjustment_id: bsa_item1[:parent_id], actual_quantity: 30)

      PackMaterialApp::TransactionsRepo.any_instance.stubs(:system_quantity).returns(25.0)
      items = repo.separate_items(bsa_item1[:parent_id])

      destroy_ids = items[:destroy_stock_items].map { |r| r[:id] }
      assert destroy_ids.include?(bsa_item1[:id])
      assert destroy_ids.include?(bsa_item2[:id])

      create_ids = items[:create_stock_items].map { |r| r[:id] }
      assert create_ids.include?(bsa_item3[:id])
      assert create_ids.include?(bsa_item4[:id])
    end

    private

    def repo
      BulkStockAdjustmentRepo.new
    end
  end
end
