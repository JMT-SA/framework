# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  class TestCreateSKUSRepo < MiniTestWithHooks
    include PmProductFactory
    include ConfigFactory

    def test_delivery_process_id
      assert_equal repo.delivery_process_id, @fixed_table_set[:processes][:delivery_process_id]
    end

    def test_create_skus_for_delivery
      term_id = DB[:mr_delivery_terms].insert(is_consignment_stock: true)
      po = DB[:mr_purchase_orders].insert(
        purchase_order_number: 5,
        mr_delivery_term_id: term_id
      )
      mr_delivery_id = DB[:mr_deliveries].insert(
        driver_name: 'Jack',
        vehicle_registration: 123,
        client_delivery_ref_number: 12
      )

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
      item_id = DB[:mr_delivery_items].insert(
        mr_delivery_id: mr_delivery_id,
        mr_product_variant_id: pv2[:id],
        mr_purchase_order_item_id: po_item_id
      )
      owner_party_id = rand(12)
      MasterfilesApp::PartyRepo.any_instance.stubs(:implementation_owner_party_role)
                               .returns(OpenStruct.new(id: owner_party_id))
      #
      # CreateSKUSRepo.any_instance.stubs(:prep_item_attrs)
      #               .returns(mr_product_variant_id: 609,
      #                        is_consignment_stock: true,
      #                        owner_party_role_id: nil)
      # CreateSKUSRepo.any_instance.stubs(:find_or_create_sku)
      #               .returns(1)

      sku_ids = repo.create_skus_for_delivery(mr_delivery_id)
      assert (sku1 = DB[:mr_skus].where(mr_product_variant_id: pv1[:id], mr_delivery_item_batch_id: batch_one_id).get(:id))
      assert (sku2 = DB[:mr_skus].where(mr_product_variant_id: pv1[:id], mr_delivery_item_batch_id: batch_two_id).get(:id))
      assert (sku3 = DB[:mr_skus].where(mr_product_variant_id: pv2[:id], mr_internal_batch_number_id: int_batch_id).get(:id))
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
      del = DB[:mr_deliveries].insert(
        driver_name: 'Jack',
        vehicle_registration: 123,
        client_delivery_ref_number: 12
      )
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
      attrs = repo.prep_item_attrs(item, pv[:id])
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
      assert_instance_of(MasterfilesApp::PartyRepo, CreateSKUSRepo.new.party_repo)
    end

    private

    def repo
      CreateSKUSRepo.new
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
