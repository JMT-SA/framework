# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  class TestMoveMrStock < MiniTestInteractors
    def test_initialize
      PackMaterialApp::MrStockRepo.any_instance.stubs(:resolve_parent_transaction_id).returns(16)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:resolve_business_process_id).returns(15)
      PackMaterialApp::ReplenishRepo.any_instance.stubs(:find_mr_delivery).returns(OpenStruct.new(receipt_location_id: 20))
      options = opts
      options[:delivery_id] = 5
      service = MoveMrStock.new(1, 2, 7, options)

      assert service.instance_variable_get('@repo').is_a?(MrStockRepo)
      assert service.instance_variable_get('@transaction_repo').is_a?(TransactionsRepo)
      assert service.instance_variable_get('@replenish_repo').is_a?(ReplenishRepo)
      assert_equal 2, service.instance_variable_get('@to_location_id')
      assert_equal 20, service.instance_variable_get('@from_location_id')
      assert_equal 7, service.instance_variable_get('@quantity')
      assert_equal 1, service.instance_variable_get('@sku_id')
      assert_equal options, service.instance_variable_get('@opts')
      assert_equal 15, service.instance_variable_get('@business_process_id')
      assert_equal 16, service.instance_variable_get('@parent_transaction_id')

      service = MoveMrStock.new(1, 2, 7, opts)
      assert_equal 3, service.instance_variable_get('@from_location_id')
    end

    def test_to_location_does_not_exist_fail
      PackMaterialApp::MrStockRepo.any_instance.stubs(:exists?).returns(false)
      service = MoveMrStock.call(1, 2, 7, opts)
      refute service.success
      assert_equal 'To location does not exist', service.message
    end

    def test_from_location_does_not_exist_fail
      PackMaterialApp::MrStockRepo.any_instance.stubs(:exists?).returns(true)
      options = opts
      options[:from_location_id] = nil

      service = MoveMrStock.call(1, 2, 7, options)
      refute service.success
      assert_equal 'From location does not exist', service.message
    end

    def test_create_and_update_sku_location_quantity_fail
      first_failed_message = 'first_fail'
      second_failed_message = 'second_fail'
      PackMaterialApp::MrStockRepo.any_instance.stubs(:exists?).returns(true)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:create_sku_location_ids).returns(bad_response(message: first_failed_message))
      PackMaterialApp::MrStockRepo.any_instance.stubs(:update_sku_location_quantity).returns(bad_response(message: second_failed_message))

      service = MoveMrStock.call(1, 2, 7, opts)
      refute service.success
      assert_equal first_failed_message, service.message

      PackMaterialApp::MrStockRepo.any_instance.stubs(:create_sku_location_ids).returns(ok_response)
      service = MoveMrStock.call(1, 2, 7, opts)
      refute service.success
      assert_equal second_failed_message, service.message
    end

    def test_invalid_parent_transaction_fail
      PackMaterialApp::MrStockRepo.any_instance.stubs(:resolve_parent_transaction_id).returns(16)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:resolve_business_process_id).returns(15)

      failed_message = 'Invalid Parent Transaction Id'
      PackMaterialApp::MrStockRepo.any_instance.stubs(:exists?).returns(true)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:create_sku_location_ids).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:update_sku_location_quantity).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:activate_mr_inventory_transaction).returns(bad_response(message: failed_message))

      service = MoveMrStock.call(1, 2, 7, opts)
      refute service.success
      assert_equal failed_message, service.message
    end

    def test_create_parent_transaction_fail
      options = opts
      options.delete(:parent_transaction_id)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:exists?).returns(true)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:update_sku_location_quantity).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:transaction_type_id_for).returns(1)

      assert_raises(Sequel::ForeignKeyConstraintViolation) {
        MoveMrStock.call(1, 2, 7, options)
      }
    end

    def test_create_transaction_item
      PackMaterialApp::MrStockRepo.any_instance.stubs(:exists?).returns(true)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:sku_uom_id).returns(20)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:update_sku_location_quantity).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:transaction_type_id_for).returns(1)
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:create_mr_inventory_transaction).returns(15)
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:create_mr_inventory_transaction_item).returns(15)

      service = MoveMrStock.call(1, 2, 7, opts)
      assert service.success
      assert_equal 15, service.instance
      assert_equal 'ok', service.message
    end

    def test_ensure_method_calls
      options = opts
      options[:delivery_id] = 5

      mocked_method = MiniTest::Mock.new
      mocked_method.expect :update_delivery_putaway_id, 20, []
      mocked_method.expect :sku_uom_id, 20, []

      PackMaterialApp::MrStockRepo.any_instance.stubs(:update_delivery_putaway_id).returns(mocked_method.update_delivery_putaway_id)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:sku_uom_id).returns(mocked_method.sku_uom_id)

      PackMaterialApp::ReplenishRepo.any_instance.stubs(:find_mr_delivery).returns(OpenStruct.new(receipt_location_id: 20))
      PackMaterialApp::MrStockRepo.any_instance.stubs(:exists?).returns(true)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:sku_uom_id).returns(20)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:update_sku_location_quantity).returns(ok_response)
      PackMaterialApp::MrStockRepo.any_instance.stubs(:transaction_type_id_for).returns(1)
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:create_mr_inventory_transaction).returns(15)
      PackMaterialApp::TransactionsRepo.any_instance.stubs(:create_mr_inventory_transaction_item).returns(15)

      service = MoveMrStock.call(1, 2, 7, options)
      assert service.success
      assert_equal 15, service.instance
      assert_equal 'ok', service.message
      assert mocked_method.verify
    end

    def opts
      {
        tripsheet_id: 1,
        is_adhoc: true,
        business_process_id: 15,
        from_location_id: 3,
        user_name: 'User Name',
        parent_transaction_id: 16,
        ref_no: 'ref_no'
      }
    end
  end
end