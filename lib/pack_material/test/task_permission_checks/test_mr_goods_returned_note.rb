# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestMrGoodsReturnedNotePermission < Minitest::Test
    include Crossbeams::Responses
    include PmProductFactory
    include MrGoodsReturnedNoteFactory

    # def entity(attrs = {})
    #   base_attrs = {
    #     id: 1,
    #     mr_delivery_id: 1,
    #     issue_transaction_id: 1,
    #     created_by: Faker::Lorem.unique.word,
    #     remarks: 'ABC'
    #   }
    #   PackMaterialApp::MrGoodsReturnedNote.new(base_attrs.merge(attrs))
    # end
    #
    # def test_create
    #   res = PackMaterialApp::TaskPermissionCheck::MrGoodsReturnedNote.call(:create)
    #   assert res.success, 'Should always be able to create a mr_goods_returned_note'
    # end
    #
    # def test_edit
    #   PackMaterialApp::DispatchRepo.any_instance.stubs(:find_mr_goods_returned_note).returns(entity)
    #   res = PackMaterialApp::TaskPermissionCheck::MrGoodsReturnedNote.call(:edit, 1)
    #   assert res.success, 'Should be able to edit a mr_goods_returned_note'
    #
    #   # PackMaterialApp::DispatchRepo.any_instance.stubs(:find_mr_goods_returned_note).returns(entity(completed: true))
    #   # res = PackMaterialApp::TaskPermissionCheck::MrGoodsReturnedNote.call(:edit, 1)
    #   # refute res.success, 'Should not be able to edit a completed mr_goods_returned_note'
    # end
    #
    # def test_delete
    #   PackMaterialApp::DispatchRepo.any_instance.stubs(:find_mr_goods_returned_note).returns(entity)
    #   res = PackMaterialApp::TaskPermissionCheck::MrGoodsReturnedNote.call(:delete, 1)
    #   assert res.success, 'Should be able to delete a mr_goods_returned_note'
    #
    #   # PackMaterialApp::DispatchRepo.any_instance.stubs(:find_mr_goods_returned_note).returns(entity(completed: true))
    #   # res = PackMaterialApp::TaskPermissionCheck::MrGoodsReturnedNote.call(:delete, 1)
    #   # refute res.success, 'Should not be able to delete a completed mr_goods_returned_note'
    # end
  end
end
