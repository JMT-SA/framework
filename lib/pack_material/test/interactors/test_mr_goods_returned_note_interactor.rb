# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestMrGoodsReturnedNoteInteractor < MiniTestWithHooks
    include PmProductFactory
    include MrGoodsReturnedNoteFactory

    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(PackMaterialApp::DispatchRepo)
    end

    def test_mr_goods_returned_note
      PackMaterialApp::DispatchRepo.any_instance.stubs(:find_mr_goods_returned_note).returns(fake_mr_goods_returned_note)
      entity = interactor.send(:mr_goods_returned_note, 1)
      assert entity.is_a?(MrGoodsReturnedNote)
    end

    def test_create_mr_goods_returned_note
      attrs = fake_mr_goods_returned_note.to_h.reject { |k, _| k == :id }
      res = interactor.create_mr_goods_returned_note(attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(MrGoodsReturnedNote, res.instance)
      assert res.instance.id.nonzero?
    end

    def test_create_mr_goods_returned_note_fail
      attrs = fake_mr_goods_returned_note(mr_delivery_id: nil).to_h.reject { |k, _| k == :id }
      res = interactor.create_mr_goods_returned_note(attrs)
      refute res.success, 'should fail validation'
      assert_equal ['must be filled'], res.errors[:mr_delivery_id]
    end

    def test_update_mr_goods_returned_note
      grn = create_mr_goods_returned_note
      id = grn[:id]
      attrs = interactor.send(:repo).find_hash(:mr_goods_returned_notes, id).reject { |k, _| k == :id }
      value = attrs[:created_by]
      attrs[:created_by] = 'a_change'
      res = interactor.update_mr_goods_returned_note(id, attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(MrGoodsReturnedNote, res.instance)
      assert_equal 'a_change', res.instance.created_by
      refute_equal value, res.instance.created_by
    end

    def test_update_mr_goods_returned_note_fail
      id = create_mr_goods_returned_note[:id]
      attrs = interactor.send(:repo).find_hash(:mr_goods_returned_notes, id).reject { |k, _| %i[id mr_delivery_id].include?(k) }
      res = interactor.update_mr_goods_returned_note(id, attrs)
      refute res.success, "#{res.message} : #{res.errors.inspect}"
      assert_equal ['is missing'], res.errors[:mr_delivery_id]
    end

    def test_delete_mr_goods_returned_note
      id = create_mr_goods_returned_note[:id]
      assert_count_changed(:mr_goods_returned_notes, -1) do
        res = interactor.delete_mr_goods_returned_note(id)
        assert res.success, res.message
      end
    end

    private

    def mr_goods_returned_note_attrs
      mr_delivery_id = create_mr_delivery[:id]
      transaction = create_transaction[:id]
      {
        id: 1,
        mr_delivery_id: mr_delivery_id,
        issue_transaction_id: transaction,
        dispatch_location_id: @fixed_table_set[:locations][:disp_loc_id],
        created_by: Faker::Lorem.unique.word,
        delivery_number: mr_delivery_id,
        credit_note_number: mr_delivery_id,
        remarks: 'ABC',
        shipped: false,
        invoice_completed: false,
        status: 'CREATED',
        created_at: DateTime.now,
        updated_at: DateTime.now
      }
    end

    def fake_mr_goods_returned_note(overrides = {})
      MrGoodsReturnedNote.new(mr_goods_returned_note_attrs.merge(overrides))
    end

    def interactor
      @interactor ||= MrGoodsReturnedNoteInteractor.new(current_user, {}, {}, {})
    end
  end
end
