# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestMrGoodsReturnedNoteItemPermission < Minitest::Test
    include Crossbeams::Responses
    include PmProductFactory
    include MrGoodsReturnedNoteFactory

    # def entity(attrs = {})
    #   base_attrs = {
    #     id: 1,
    #     mr_goods_returned_note_id: 1,
    #     mr_delivery_item_id: 1,
    #     mr_delivery_item_batch_id: 1,
    #     remarks: Faker::Lorem.unique.word,
    #     quantity_returned: 1.0
    #   }
    #   PackMaterialApp::MrGoodsReturnedNoteItem.new(base_attrs.merge(attrs))
    # end
    #
    # def test_create
    #   res = PackMaterialApp::TaskPermissionCheck::MrGoodsReturnedNoteItem.call(:create, 1)
    #   assert res.success, 'Should always be able to create a mr_goods_returned_note_item'
    # end
    #
    # def test_edit
    #   PackMaterialApp::DispatchRepo.any_instance.stubs(:find_mr_goods_returned_note_item).returns(entity)
    #   res = PackMaterialApp::TaskPermissionCheck::MrGoodsReturnedNoteItem.call(:edit, 1)
    #   assert res.success, 'Should be able to edit a mr_goods_returned_note_item'
    #
    #   # PackMaterialApp::DispatchRepo.any_instance.stubs(:find_mr_goods_returned_note_item).returns(entity(completed: true))
    #   # res = PackMaterialApp::TaskPermissionCheck::MrGoodsReturnedNoteItem.call(:edit, 1)
    #   # refute res.success, 'Should not be able to edit a completed mr_goods_returned_note_item'
    # end
    #
    # def test_delete
    #   PackMaterialApp::DispatchRepo.any_instance.stubs(:find_mr_goods_returned_note_item).returns(entity)
    #   res = PackMaterialApp::TaskPermissionCheck::MrGoodsReturnedNoteItem.call(:delete, 1)
    #   assert res.success, 'Should be able to delete a mr_goods_returned_note_item'
    #
    #   # PackMaterialApp::DispatchRepo.any_instance.stubs(:find_mr_goods_returned_note_item).returns(entity(completed: true))
    #   # res = PackMaterialApp::TaskPermissionCheck::MrGoodsReturnedNoteItem.call(:delete, 1)
    #   # refute res.success, 'Should not be able to delete a completed mr_goods_returned_note_item'
    # end
  end
end
