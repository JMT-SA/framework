# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestDispatchRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_mr_goods_returned_notes
    end

    def test_crud_calls
      test_crud_calls_for :mr_goods_returned_notes, name: :mr_goods_returned_note, wrapper: MrGoodsReturnedNote
    end

    private

    def repo
      DispatchRepo.new
    end
  end
end
