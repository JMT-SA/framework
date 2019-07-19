# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestCreateMrStock < MiniTestInteractors
    def test_initialize
      sku_ids = [1, 2, 3]
      service = CreateMrStock.new(sku_ids, opts)

      assert service.instance_variable_get('@repo').is_a?(MrStockRepo)
      assert service.instance_variable_get('@transaction_repo').is_a?(TransactionsRepo)
      assert_equal sku_ids, service.instance_variable_get('@sku_ids')
      assert_equal 7, service.instance_variable_get('@business_process_id')
      assert_equal 3, service.instance_variable_get('@to_location_id')
      assert_equal 4, service.instance_variable_get('@delivery_id')
      assert_equal 'ref_no', service.instance_variable_get('@ref_no')
      assert_equal 5, service.instance_variable_get('@parent_transaction_id')
      assert_equal opts, service.instance_variable_get('@opts')
      assert_nil service.instance_variable_get('@quantities')

      options = opts
      options.delete(:delivery_id)
      service = CreateMrStock.new(sku_ids, options)

      assert_equal options[:quantities], service.instance_variable_get('@quantities')
    end

    def test_no_sku_ids_fail
      service = CreateMrStock.call([], opts)
      refute service.success
      assert_equal 'Stock can not be created without sku_ids', service.message
    end

    def test_create_sku_location_ids_fail
      PackMaterialApp::MrStockRepo.any_instance.stubs(:create_sku_location_ids).returns(bad_response)
      service = CreateMrStock.call([1, 2, 3], opts)
      refute service.success
      assert_equal 'FAILED', service.message
    end

    def test_invalid_parent_transaction_fail
      failed_message = 'Invalid Parent Transaction Id'
      PackMaterialApp::MrStockRepo.any_instance.stubs(:create_sku_location_ids).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:activate_mr_inventory_transaction).returns(bad_response(message: failed_message))

      service = CreateMrStock.call([1, 2, 3], opts)
      refute service.success
      assert_equal failed_message, service.message
    end

    def test_create_parent_transaction_fail
      options = opts
      options.delete(:parent_transaction_id)

      PackMaterialApp::MrStockRepo.any_instance.stubs(:create_sku_location_ids).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:transaction_type_id_for).returns(1)

      assert_raises(Sequel::ForeignKeyConstraintViolation) { CreateMrStock.call([1, 2, 3], options) }
    end

    def test_delivery_id
      # invalid_delivery_fail
      failed_message = 'Delivery does not exist'
      PackMaterialApp::MrStockRepo.any_instance.stubs(:create_sku_location_ids).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:activate_mr_inventory_transaction).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:update_delivery_receipt_id).returns(bad_response(message: failed_message))

      service = CreateMrStock.call([1, 2, 3], opts)
      refute service.success
      assert_equal failed_message, service.message

      # ensure called if delivery id
      PackMaterialApp::MrStockRepo.any_instance.stubs(:update_delivery_receipt_id).returns(ok_response)
      mocked_method = MiniTest::Mock.new
      mocked_method.expect :get_delivery_sku_quantities, ok_response, []
      PackMaterialApp::MrStockRepo.any_instance.stubs(:get_delivery_sku_quantities).returns(mocked_method.get_delivery_sku_quantities)

      CreateMrStock.call([1, 2, 3], opts)
      assert mocked_method.verify

      # ensure not called if no delivery id
      options = opts
      options.delete(:delivery_id)
      second_mocked_method = MiniTest::Mock.new
      second_mocked_method.expect :update_delivery_receipt_id, ok_response, []
      second_mocked_method.expect :get_delivery_sku_quantities, ok_response, []
      CreateMrStock.call([1, 2, 3], options)
      assert_raises(MockExpectationError) { second_mocked_method.verify }
    end

    def test_add_sku_location_quantities_fail
      failed_message = 'FAILED'
      PackMaterialApp::MrStockRepo.any_instance.stubs(:create_sku_location_ids).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:activate_mr_inventory_transaction).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:update_delivery_receipt_id).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:get_delivery_sku_quantities).returns(true)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:add_sku_location_quantities).returns(bad_response(message: failed_message))

      service = CreateMrStock.call([1, 2, 3], opts)
      refute service.success
      assert_equal failed_message, service.message
    end

    def test_create_transaction_per_quantity
      PackMaterialApp::MrStockRepo.any_instance.stubs(:create_sku_location_ids).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:activate_mr_inventory_transaction).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:update_delivery_receipt_id).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:get_delivery_sku_quantities).returns(
        [{ sku_id: 5, qty: 5 }, { sku_id: 6, qty: 6 }]
      )
      PackMaterialApp::MrStockRepo.any_instance.stubs(:add_sku_location_quantities).returns(ok_response)
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:create_mr_inventory_transaction_item).returns(15)

      service = CreateMrStock.call([1, 2, 3], opts)
      assert service.success
      exp = { parent_transaction_id: 5, transaction_item_ids: [{ sku_id: 5, qty: 5, transaction_item_id: 15 }, { sku_id: 6, qty: 6, transaction_item_id: 15 }] }
      assert_equal exp, service.instance
      assert_equal 'ok', service.message
    end

    def opts
      {
        business_process_id: 7,
        to_location_id: 3,
        delivery_id: 4,
        ref_no: 'ref_no',
        parent_transaction_id: 5,
        quantities: [{ sku_id: 15, qty: 20 }],
        user_name: 'User Name'
      }
    end
  end
end
