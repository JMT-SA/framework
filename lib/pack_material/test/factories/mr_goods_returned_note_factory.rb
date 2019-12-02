# frozen_string_literal: true

module PackMaterialApp
  module MrGoodsReturnedNoteFactory
    def create_mr_goods_returned_note(opts = {})
      mr_delivery_id = create_mr_delivery[:id]
      transaction = create_transaction[:id]
      default = {
        mr_delivery_id: mr_delivery_id,
        issue_transaction_id: transaction,
        dispatch_location_id: @fixed_table_set[:locations][:disp_loc_id],
        created_by: Faker::Lorem.unique.word,
        remarks: Faker::Lorem.word,
        created_at: '2010-01-01 12:00',
        updated_at: '2010-01-01 12:00'
      }
      id = DB[:mr_goods_returned_notes].insert(default.merge(opts))
      {
        id: id
      }
    end

    def create_mr_goods_returned_note_item(opts = {})
      mr_goods_returned_note_id = create_mr_goods_returned_note[:id]
      mr_delivery_item_id = create_mr_delivery_item
      mr_delivery_item_batch_id = create_mr_delivery_item_batch

      default = {
        mr_goods_returned_note_id: mr_goods_returned_note_id,
        mr_delivery_item_id: mr_delivery_item_id,
        mr_delivery_item_batch_id: mr_delivery_item_batch_id,
        remarks: Faker::Lorem.unique.word,
        quantity_returned: Faker::Number.decimal,
        created_at: '2010-01-01 12:00',
        updated_at: '2010-01-01 12:00'
      }
      id = DB[:mr_goods_returned_note_items].insert(default.merge(opts))
      {
        id: id
      }
    end
  end
end
