# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestMrStockRepo < MiniTestWithHooks
    include PmProductFactory
    include ConfigFactory
    include MasterfilesApp::PartyFactory

    def test_delivery_process_id
      assert_equal repo.delivery_process_id, @fixed_table_set[:processes][:delivery_process_id]
    end

    def test_create_skus_for_delivery
      term_id = DB[:mr_delivery_terms].insert(is_consignment_stock: true)
      po = DB[:mr_purchase_orders].insert(
        purchase_order_number: 5,
        mr_delivery_term_id: term_id
      )
      mr_delivery_id = create_mr_delivery[:id]

      pv1 = create_material_resource_product_variant
      po_item_id = DB[:mr_purchase_order_items].insert(
        mr_purchase_order_id: po,
        mr_product_variant_id: pv1[:id]
      )
      item_id = DB[:mr_delivery_items].insert(
        mr_delivery_id: mr_delivery_id,
        mr_product_variant_id: pv1[:id],
        mr_purchase_order_item_id: po_item_id
      )
      batch_one_id = DB[:mr_delivery_item_batches].insert(
        mr_delivery_item_id: item_id,
        client_batch_number: 'one',
        quantity_on_note: 5,
        quantity_received: 5
      )
      batch_two_id = DB[:mr_delivery_item_batches].insert(
        mr_delivery_item_id: item_id,
        client_batch_number: 'two',
        quantity_on_note: 5,
        quantity_received: 5
      )

      int_batch_id = DB[:mr_internal_batch_numbers].insert(batch_number: 2345)
      pv2 = create_material_resource_product_variant(use_fixed_batch_number: true, mr_internal_batch_number_id: int_batch_id)
      po_item_id = DB[:mr_purchase_order_items].insert(
        mr_purchase_order_id: po,
        mr_product_variant_id: pv2[:id]
      )
      DB[:mr_delivery_items].insert(
        mr_delivery_id: mr_delivery_id,
        mr_product_variant_id: pv2[:id],
        mr_purchase_order_item_id: po_item_id
      )
      owner_party_id = rand(12)
      MasterfilesApp::PartyRepo.any_instance.stubs(:implementation_owner_party_role)
                               .returns(OpenStruct.new(id: owner_party_id))
      #
      # MrStockRepo.any_instance.stubs(:prep_item_attrs)
      #               .returns(mr_product_variant_id: 609,
      #                        is_consignment_stock: true,
      #                        owner_party_role_id: nil)
      # MrStockRepo.any_instance.stubs(:find_or_create_sku)
      #               .returns(1)

      sku_ids = repo.create_skus_for_delivery(mr_delivery_id)
      sku1 = DB[:mr_skus].where(mr_product_variant_id: pv1[:id], mr_delivery_item_batch_id: batch_one_id).get(:id)
      sku2 = DB[:mr_skus].where(mr_product_variant_id: pv1[:id], mr_delivery_item_batch_id: batch_two_id).get(:id)
      sku3 = DB[:mr_skus].where(mr_product_variant_id: pv2[:id], mr_internal_batch_number_id: int_batch_id).get(:id)

      assert sku1
      assert sku2
      assert sku3
      assert_includes sku_ids, sku1
      assert_includes sku_ids, sku2
      assert_includes sku_ids, sku3
      assert_equal sku_ids.count, 3
    end

    def test_prep_item_attrs
      pv = create_material_resource_product_variant
      term_id = DB[:mr_delivery_terms].insert(is_consignment_stock: true)
      owner_party_id = rand(12)
      MasterfilesApp::PartyRepo.any_instance.stubs(:implementation_owner_party_role)
                               .returns(OpenStruct.new(id: owner_party_id))
      po = DB[:mr_purchase_orders].insert(
        purchase_order_number: 5,
        mr_delivery_term_id: term_id
      )
      po_item_id = DB[:mr_purchase_order_items].insert(
        mr_purchase_order_id: po,
        mr_product_variant_id: pv[:id]
      )
      del = create_mr_delivery[:id]
      item_id = DB[:mr_delivery_items].insert(
        mr_delivery_id: del,
        mr_product_variant_id: pv[:id],
        mr_purchase_order_item_id: po_item_id
      )
      item = DB[:mr_delivery_items].where(id: item_id).first

      attrs = repo.prep_item_attrs(item, pv[:id])
      assert_equal attrs[:mr_product_variant_id], pv[:id]
      assert_equal attrs[:is_consignment_stock], true
      assert_nil attrs[:owner_party_role_id]

      DB[:mr_delivery_terms].update(id: term_id, is_consignment_stock: false)
      attrs = repo.send(:prep_item_attrs, item, pv[:id])
      assert_equal attrs[:is_consignment_stock], false
      assert_equal attrs[:owner_party_role_id], owner_party_id
    end

    def test_find_or_create_sku
      pv = create_material_resource_product_variant
      batch_id = DB[:mr_internal_batch_numbers].insert(batch_number: 123, description: 'desc')
      sku_attrs = {
        mr_internal_batch_number_id: batch_id,
        mr_product_variant_id: pv[:id]
      }

      assert_empty DB[:mr_skus].where(sku_attrs).all
      sku_id = repo.find_or_create_sku(sku_attrs)
      assert_equal sku_id, repo.find_or_create_sku(sku_attrs)
    end

    def test_party_repo
      assert_instance_of(MasterfilesApp::PartyRepo, MrStockRepo.new.party_repo)
    end

    def test_resolve_parent_transaction_id
      inv_trans_id = DB[:mr_inventory_transactions].insert(
        mr_inventory_transaction_type_id: @fixed_table_set[:inventory_transaction_types][:create_stock_id],
        business_process_id: @fixed_table_set[:processes][:bulk_stock_adjustments_process_id],
        created_by: 'current user'
      )
      delivery_id = create_mr_delivery(putaway_transaction_id: inv_trans_id)[:id]

      assert 5, repo.resolve_parent_transaction_id(delivery_id: delivery_id)
      assert_nil repo.resolve_parent_transaction_id(tripsheet_id: 1)
      assert 1, repo.resolve_parent_transaction_id(parent_transaction_id: 1)
    end

    def test_resolve_business_process_id
      business_process_id = rand(5)
      assert @fixed_table_set[:processes][:delivery_process_id], repo.resolve_business_process_id(delivery_id: 1)
      assert @fixed_table_set[:processes][:vehicle_job_process_id], repo.resolve_business_process_id(tripsheet_id: 1)
      assert @fixed_table_set[:processes][:adhoc_transactions_process_id], repo.resolve_business_process_id(is_adhoc: 1)
      assert business_process_id, repo.resolve_business_process_id(business_process_id: business_process_id)
    end

    def test_transaction_type_id_for
      assert @fixed_table_set[:inventory_transaction_types][:create_stock_id], repo.transaction_type_id_for('create')
      assert @fixed_table_set[:inventory_transaction_types][:putaway_id], repo.transaction_type_id_for('adhoc')
      assert @fixed_table_set[:inventory_transaction_types][:adhoc_move_id], repo.transaction_type_id_for('else')
    end

    def test_update_delivery_receipt_id
      receipt_id = DB[:mr_inventory_transactions].insert(
        mr_inventory_transaction_type_id: @fixed_table_set[:inventory_transaction_types][:create_stock_id],
        business_process_id: @fixed_table_set[:processes][:bulk_stock_adjustments_process_id],
        created_by: 'current user'
      )
      delivery_id = create_mr_delivery[:id]
      repo.update_delivery_receipt_id(delivery_id, receipt_id)
      assert_equal receipt_id, DB[:mr_deliveries].where(id: delivery_id).get(:receipt_transaction_id)
      assert_equal DB[:mr_deliveries].where(id: delivery_id).get(:receipt_transaction_id), repo.delivery_receipt_id(delivery_id)
    end

    def test_get_delivery_sku_quantities
      term_id = DB[:mr_delivery_terms].insert(is_consignment_stock: true)
      po = DB[:mr_purchase_orders].insert(
        purchase_order_number: 5,
        mr_delivery_term_id: term_id
      )
      mr_delivery_id = create_mr_delivery[:id]

      pv1 = create_material_resource_product_variant
      po_item_id = DB[:mr_purchase_order_items].insert(
        mr_purchase_order_id: po,
        mr_product_variant_id: pv1[:id]
      )
      item_id = DB[:mr_delivery_items].insert(
        mr_delivery_id: mr_delivery_id,
        mr_product_variant_id: pv1[:id],
        mr_purchase_order_item_id: po_item_id
      )
      batch_one_id = DB[:mr_delivery_item_batches].insert(
        mr_delivery_item_id: item_id,
        client_batch_number: 'one',
        quantity_on_note: 5,
        quantity_received: 5
      )
      batch_two_id = DB[:mr_delivery_item_batches].insert(
        mr_delivery_item_id: item_id,
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
      DB[:mr_delivery_items].insert(
        mr_delivery_id: mr_delivery_id,
        mr_product_variant_id: pv2[:id],
        mr_purchase_order_item_id: po_item_id,
        quantity_received: 15
      )

      sku1_id = DB[:mr_skus].insert(mr_product_variant_id: pv1[:id], mr_delivery_item_batch_id: batch_one_id)
      sku2_id = DB[:mr_skus].insert(mr_product_variant_id: pv1[:id], mr_delivery_item_batch_id: batch_two_id)
      sku3_id = DB[:mr_skus].insert(mr_product_variant_id: pv2[:id], mr_internal_batch_number_id: int_batch_id)

      qty1 = DB[:mr_delivery_item_batches].where(id: batch_one_id).get(:quantity_received)
      qty2 = DB[:mr_delivery_item_batches].where(id: batch_two_id).get(:quantity_received)
      qty3 = DB[:mr_delivery_item_batches].where(id: int_batch_id).get(:quantity_received)
      quantities = [
        { sku_id: sku1_id, qty: qty1 },
        { sku_id: sku2_id, qty: qty2 },
        { sku_id: sku3_id, qty: qty3 }
      ]
      assert quantities, repo.get_delivery_sku_quantities(mr_delivery_id)
    end

    def test_create_sku_location_ids
      pv = create_material_resource_product_variant[:id]
      sku1_id = DB[:mr_skus].insert(mr_product_variant_id: pv, sku_number: 1)
      sku2_id = DB[:mr_skus].insert(mr_product_variant_id: pv, sku_number: 2)
      sku3_id = DB[:mr_skus].insert(mr_product_variant_id: pv, sku_number: 3)

      bay_id = @fixed_table_set[:locations][:default_id]

      repo.create_sku_location_ids([sku1_id, sku2_id, sku3_id], bay_id)
      assert DB[:mr_sku_locations].where(mr_sku_id: sku1_id, location_id: bay_id).first
      assert DB[:mr_sku_locations].where(mr_sku_id: sku2_id, location_id: bay_id).first
      assert DB[:mr_sku_locations].where(mr_sku_id: sku3_id, location_id: bay_id).first
    end

    def test_add_sku_location_quantities
      to_location_id = DB[:locations].insert(
        primary_storage_type_id: @fixed_table_set[:locations][:storage_type_id],
        location_type_id: @fixed_table_set[:locations][:type_id],
        primary_assignment_id: @fixed_table_set[:locations][:assignment_id],
        location_description: 'Pack Material Store',
        location_long_code: 'PM STORE 1',
        location_short_code: 'PM1',
        can_store_stock: true
      )

      pv = create_material_resource_product_variant[:id]
      sku1_id = DB[:mr_skus].insert(mr_product_variant_id: pv, sku_number: 1)
      sku2_id = DB[:mr_skus].insert(mr_product_variant_id: pv, sku_number: 2)
      sku3_id = DB[:mr_skus].insert(mr_product_variant_id: pv, sku_number: 3)

      repo.create_sku_location_ids([sku1_id, sku2_id, sku3_id], to_location_id)

      qty1 = 10
      qty2 = 20
      qty3 = 50

      quantities = [
        { sku_id: sku1_id, qty: qty1 },
        { sku_id: sku2_id, qty: qty2 },
        { sku_id: sku3_id, qty: qty3 }
      ]
      repo.add_sku_location_quantities(quantities, to_location_id)
      assert_equal qty1, DB[:mr_sku_locations].where(mr_sku_id: sku1_id).get(:quantity)
      assert_equal qty2, DB[:mr_sku_locations].where(mr_sku_id: sku2_id).get(:quantity)
      assert_equal qty3, DB[:mr_sku_locations].where(mr_sku_id: sku3_id).get(:quantity)
    end

    def test_update_sku_location_quantity
      to_location_id = DB[:locations].insert(
        primary_storage_type_id: @fixed_table_set[:locations][:storage_type_id],
        location_type_id: @fixed_table_set[:locations][:type_id],
        primary_assignment_id: @fixed_table_set[:locations][:assignment_id],
        location_description: 'Pack Material Store',
        location_long_code: 'PM STORE 1',
        location_short_code: 'PM1',
        can_store_stock: true
      )

      pv = create_material_resource_product_variant[:id]
      sku1_id = DB[:mr_skus].insert(mr_product_variant_id: pv, sku_number: 1)
      sku2_id = DB[:mr_skus].insert(mr_product_variant_id: pv, sku_number: 2)
      sku3_id = DB[:mr_skus].insert(mr_product_variant_id: pv, sku_number: 3)

      repo.create_sku_location_ids([sku1_id, sku2_id, sku3_id], to_location_id)

      qty1 = 10
      qty2 = 20
      qty3 = 50

      quantities = [
        { sku_id: sku1_id, qty: qty1 },
        { sku_id: sku2_id, qty: qty2 },
        { sku_id: sku3_id, qty: qty3 }
      ]
      repo.add_sku_location_quantities(quantities, to_location_id)
      assert_equal qty1, DB[:mr_sku_locations].where(mr_sku_id: sku1_id).get(:quantity)
      assert_equal qty2, DB[:mr_sku_locations].where(mr_sku_id: sku2_id).get(:quantity)
      assert_equal qty3, DB[:mr_sku_locations].where(mr_sku_id: sku3_id).get(:quantity)

      repo.update_sku_location_quantity(sku1_id, 5, to_location_id, add: true)
      assert_equal 15, DB[:mr_sku_locations].where(mr_sku_id: sku1_id).get(:quantity)
      repo.update_sku_location_quantity(sku2_id, 10, to_location_id, add: false)
      assert_equal 10, DB[:mr_sku_locations].where(mr_sku_id: sku2_id).get(:quantity)
      repo.update_sku_location_quantity(sku3_id, 5, to_location_id, add: true)
      assert_equal 55, DB[:mr_sku_locations].where(mr_sku_id: sku3_id).get(:quantity)
    end

    def test_sku_uom_id
      pv1 = create_material_resource_product_variant
      inv_uom_id = @fixed_table_set[:uoms][:uom_id]

      int_batch_id = DB[:mr_internal_batch_numbers].insert(
        batch_number: 2,
        description: 'desc desc desc'
      )
      party_role = create_party_role

      sku_id = DB[:mr_skus].insert(
        mr_product_variant_id: pv1[:id],
        owner_party_role_id: party_role[:id],
        sku_number: 5,
        mr_internal_batch_number_id: int_batch_id
      )

      assert_equal inv_uom_id, repo.sku_uom_id(sku_id)
    end

    private

    def repo
      MrStockRepo.new
    end
  end
end
