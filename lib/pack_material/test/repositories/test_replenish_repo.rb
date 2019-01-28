# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  class TestReplenishRepo < MiniTestWithHooks
    include PmProductFactory
    include ConfigFactory

    def test_for_selects
      assert_respond_to repo, :for_select_mr_purchase_orders
    end

    def test_crud_calls
      test_crud_calls_for :mr_purchase_orders, name: :mr_purchase_order, wrapper: MrPurchaseOrder
    end

    def test_delivery_putaway_reaction_job
      ReplenishRepo.any_instance.stubs(:update_delivery_putaway_quantity).returns(success_response('ok'))
      ReplenishRepo.any_instance.stubs(:update_delivery_putaway_statuses).returns(success_response('ok'))
      ReplenishRepo.any_instance.stubs(:update_purchase_order_statuses).returns('PO STATUSES RUN')

      pv = create_material_resource_product_variant
      term_id = DB[:mr_delivery_terms].insert(is_consignment_stock: true)
      po = DB[:mr_purchase_orders].insert(
        purchase_order_number: 5,
        mr_delivery_term_id: term_id
      )
      inv_uom_id = @fixed_table_set[:uoms][:uom_id]
      po_item_id = DB[:mr_purchase_order_items].insert(
        mr_purchase_order_id: po,
        mr_product_variant_id: pv[:id],
        inventory_uom_id: inv_uom_id
      )
      mr_delivery_id = DB[:mr_deliveries].insert(
        driver_name: 'Jack',
        vehicle_registration: 123,
        client_delivery_ref_number: 12
      )
      item_id = DB[:mr_delivery_items].insert(
        mr_delivery_id: mr_delivery_id,
        mr_product_variant_id: pv[:id],
        mr_purchase_order_item_id: po_item_id
      )
      DB[:mr_delivery_item_batches].insert(
        mr_delivery_item_id: item_id,
        client_batch_number: 'one',
        quantity_on_note: 5,
        quantity_received: 5
      )
      sku_id = DB[:mr_skus].insert(mr_product_variant_id: pv[:id])
      res = repo.delivery_putaway_reaction_job(sku_id, 50, mr_delivery_id)
      assert res.success
    end

    def test_update_delivery_putaway_quantity
      pv1 = create_material_resource_product_variant
      term_id = DB[:mr_delivery_terms].insert(is_consignment_stock: true)
      po = DB[:mr_purchase_orders].insert(
        purchase_order_number: 5,
        mr_delivery_term_id: term_id
      )
      inv_uom_id = @fixed_table_set[:uoms][:uom_id]
      po_item_id = DB[:mr_purchase_order_items].insert(
        mr_purchase_order_id: po,
        mr_product_variant_id: pv1[:id],
        inventory_uom_id: inv_uom_id
      )
      mr_delivery_id = DB[:mr_deliveries].insert(
        driver_name: 'Jack',
        vehicle_registration: 123,
        client_delivery_ref_number: 12
      )
      item1_id = DB[:mr_delivery_items].insert(
        mr_delivery_id: mr_delivery_id,
        mr_product_variant_id: pv1[:id],
        mr_purchase_order_item_id: po_item_id
      )
      batch_one_id = DB[:mr_delivery_item_batches].insert(
        mr_delivery_item_id: item1_id,
        client_batch_number: 'one',
        quantity_on_note: 5,
        quantity_received: 5
      )
      batch_two_id = DB[:mr_delivery_item_batches].insert(
        mr_delivery_item_id: item1_id,
        client_batch_number: 'two',
        quantity_on_note: 10,
        quantity_received: 10
      )

      int_batch_id = DB[:mr_internal_batch_numbers].insert(batch_number: 2345)
      pv2 = create_material_resource_product_variant(use_fixed_batch_number: true, mr_internal_batch_number_id: int_batch_id)
      po_item_id = DB[:mr_purchase_order_items].insert(
        mr_purchase_order_id: po,
        mr_product_variant_id: pv2[:id]
      )
      item_id = DB[:mr_delivery_items].insert(
        mr_delivery_id: mr_delivery_id,
        mr_product_variant_id: pv2[:id],
        mr_purchase_order_item_id: po_item_id,
        quantity_received: 15
      )

      sku1_id = DB[:mr_skus].insert(mr_product_variant_id: pv1[:id], mr_delivery_item_batch_id: batch_one_id)
      sku2_id = DB[:mr_skus].insert(mr_product_variant_id: pv1[:id], mr_delivery_item_batch_id: batch_two_id)
      sku3_id = DB[:mr_skus].insert(mr_product_variant_id: pv2[:id], mr_internal_batch_number_id: int_batch_id)

      repo.update_delivery_putaway_quantity(sku1_id, 100, mr_delivery_id)
      repo.update_delivery_putaway_quantity(sku2_id, 150, mr_delivery_id)
      repo.update_delivery_putaway_quantity(sku3_id, 200, mr_delivery_id)

      assert_equal 250, DB[:mr_delivery_items].where(id: item1_id).get(:quantity_putaway)
      assert_equal 200, DB[:mr_delivery_items].where(id: item_id).get(:quantity_putaway)

      assert_equal 'PUTAWAY_COMPLETED', DB[Sequel.function(:fn_current_status, 'mr_delivery_items', item1_id)].single_value
      assert_equal 'PUTAWAY_COMPLETED', DB[Sequel.function(:fn_current_status, 'mr_delivery_items', item_id)].single_value
      assert_equal 'PUTAWAY_COMPLETED', DB[Sequel.function(:fn_current_status, 'mr_delivery_item_batches', batch_one_id)].single_value
      assert_equal 'PUTAWAY_COMPLETED', DB[Sequel.function(:fn_current_status, 'mr_delivery_item_batches', batch_two_id)].single_value
    end

    def test_update_delviery_putaway_statuses
      pv1 = create_material_resource_product_variant
      term_id = DB[:mr_delivery_terms].insert(is_consignment_stock: true)
      po = DB[:mr_purchase_orders].insert(
        purchase_order_number: 5,
        mr_delivery_term_id: term_id
      )
      inv_uom_id = @fixed_table_set[:uoms][:uom_id]
      po_item_id = DB[:mr_purchase_order_items].insert(
        mr_purchase_order_id: po,
        mr_product_variant_id: pv1[:id],
        inventory_uom_id: inv_uom_id
      )
      mr_delivery_id = DB[:mr_deliveries].insert(
        driver_name: 'Jack',
        vehicle_registration: 123,
        client_delivery_ref_number: 12
      )
      item1_id = DB[:mr_delivery_items].insert(
        mr_delivery_id: mr_delivery_id,
        mr_product_variant_id: pv1[:id],
        mr_purchase_order_item_id: po_item_id,
        quantity_received: 15
      )
      batch_one_id = DB[:mr_delivery_item_batches].insert(
        mr_delivery_item_id: item1_id,
        client_batch_number: 'one',
        quantity_on_note: 5,
        quantity_received: 5
      )
      batch_two_id = DB[:mr_delivery_item_batches].insert(
        mr_delivery_item_id: item1_id,
        client_batch_number: 'two',
        quantity_on_note: 10,
        quantity_received: 10
      )

      int_batch_id = DB[:mr_internal_batch_numbers].insert(batch_number: 2345)
      pv2 = create_material_resource_product_variant(use_fixed_batch_number: true, mr_internal_batch_number_id: int_batch_id)
      po_item_id = DB[:mr_purchase_order_items].insert(
        mr_purchase_order_id: po,
        mr_product_variant_id: pv2[:id]
      )
      item_id = DB[:mr_delivery_items].insert(
        mr_delivery_id: mr_delivery_id,
        mr_product_variant_id: pv2[:id],
        mr_purchase_order_item_id: po_item_id,
        quantity_received: 15
      )

      sku1_id = DB[:mr_skus].insert(mr_product_variant_id: pv1[:id], mr_delivery_item_batch_id: batch_one_id)
      sku2_id = DB[:mr_skus].insert(mr_product_variant_id: pv1[:id], mr_delivery_item_batch_id: batch_two_id)
      sku3_id = DB[:mr_skus].insert(mr_product_variant_id: pv2[:id], mr_internal_batch_number_id: int_batch_id)

      repo.update_delivery_putaway_quantity(sku1_id, 5, mr_delivery_id)
      repo.update_delivery_putaway_quantity(sku2_id, 5, mr_delivery_id)
      refute_equal 'PUTAWAY_COMPLETED', DB[Sequel.function(:fn_current_status, 'mr_delivery_items', item1_id)].single_value
      repo.update_delivery_putaway_quantity(sku3_id, 15, mr_delivery_id)

      repo.update_delivery_putaway_statuses(mr_delivery_id)
      refute DB[:mr_deliveries].where(id: mr_delivery_id).get(:putaway_completed)
      assert_equal 'OFFLOADING_DELIVERY', DB[Sequel.function(:fn_current_status, 'mr_deliveries', mr_delivery_id)].single_value

      repo.update_delivery_putaway_quantity(sku2_id, 5, mr_delivery_id)
      assert_equal 'PUTAWAY_COMPLETED', DB[Sequel.function(:fn_current_status, 'mr_delivery_items', item1_id)].single_value
      repo.update_delivery_putaway_statuses(mr_delivery_id)
      assert DB[:mr_deliveries].where(id: mr_delivery_id).get(:putaway_completed)
      assert_equal 'DELIVERY_OFFLOADED', DB[Sequel.function(:fn_current_status, 'mr_deliveries', mr_delivery_id)].single_value

      res = repo.update_delivery_putaway_statuses(mr_delivery_id)
      refute res.success
    end

    def test_update_purchase_order_statuses
      pv1 = create_material_resource_product_variant
      term_id = DB[:mr_delivery_terms].insert(is_consignment_stock: true)
      po = DB[:mr_purchase_orders].insert(
        purchase_order_number: 5,
        mr_delivery_term_id: term_id
      )
      inv_uom_id = @fixed_table_set[:uoms][:uom_id]
      po_item1_id = DB[:mr_purchase_order_items].insert(
        mr_purchase_order_id: po,
        mr_product_variant_id: pv1[:id],
        inventory_uom_id: inv_uom_id,
        quantity_required: 15
      )
      mr_delivery_id = DB[:mr_deliveries].insert(
        driver_name: 'Jack',
        vehicle_registration: 123,
        client_delivery_ref_number: 12
      )
      item1_id = DB[:mr_delivery_items].insert(
        mr_delivery_id: mr_delivery_id,
        mr_product_variant_id: pv1[:id],
        mr_purchase_order_item_id: po_item1_id,
        quantity_received: 15,
        quantity_putaway: 10
      )
      batch_one_id = DB[:mr_delivery_item_batches].insert(
        mr_delivery_item_id: item1_id,
        client_batch_number: 'one',
        quantity_on_note: 5,
        quantity_putaway: 5
      )
      batch_two_id = DB[:mr_delivery_item_batches].insert(
        mr_delivery_item_id: item1_id,
        client_batch_number: 'two',
        quantity_on_note: 10,
        quantity_putaway: 5
      )

      int_batch_id = DB[:mr_internal_batch_numbers].insert(batch_number: 2345)
      pv2 = create_material_resource_product_variant(use_fixed_batch_number: true, mr_internal_batch_number_id: int_batch_id)
      po_item_id = DB[:mr_purchase_order_items].insert(
        mr_purchase_order_id: po,
        mr_product_variant_id: pv2[:id],
        quantity_required: 15
      )
      item_id = DB[:mr_delivery_items].insert(
        mr_delivery_id: mr_delivery_id,
        mr_product_variant_id: pv2[:id],
        mr_purchase_order_item_id: po_item_id,
        quantity_putaway: 10
      )

      # Both items incomplete, order is receiving deliveries
      repo.update_purchase_order_statuses(po_item_id)
      assert_equal 'PO_ITEM_RECEIVING', DB[Sequel.function(:fn_current_status, 'mr_purchase_order_items', po_item_id)].single_value
      assert_equal 'RECEIVING_DELIVERIES', DB[Sequel.function(:fn_current_status, 'mr_purchase_orders', po)].single_value

      # Current item complete, other incomplete, order is receiving deliveries
      DB[:mr_delivery_items].where(id: item_id).update(quantity_putaway: 15)
      repo.update_purchase_order_statuses(po_item_id)
      assert_equal 'PO_ITEM_RECEIVED', DB[Sequel.function(:fn_current_status, 'mr_purchase_order_items', po_item_id)].single_value
      assert_equal 'RECEIVING_DELIVERIES', DB[Sequel.function(:fn_current_status, 'mr_purchase_orders', po)].single_value

      # Both items complete, order is closed
      DB[:mr_delivery_items].where(id: item1_id).update(quantity_putaway: 15)
      repo.update_purchase_order_statuses(po_item1_id)
      assert_equal 'PO_ITEM_RECEIVED', DB[Sequel.function(:fn_current_status, 'mr_purchase_order_items', po_item1_id)].single_value
      assert_equal 'PO_ITEM_RECEIVED', DB[Sequel.function(:fn_current_status, 'mr_purchase_order_items', po_item_id)].single_value
      assert_equal 'PURCHASE_ORDER_CLOSED', DB[Sequel.function(:fn_current_status, 'mr_purchase_orders', po)].single_value
    end

    private

    def repo
      ReplenishRepo.new
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
