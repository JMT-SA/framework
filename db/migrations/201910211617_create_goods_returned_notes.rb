require 'sequel_postgresql_triggers'
Sequel.migration do
  change do
    extension :pg_triggers
    create_table(:mr_goods_returned_notes, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_delivery_id, :mr_deliveries, null: false, key: [:id]
      foreign_key :issue_transaction_id, :mr_inventory_transactions, key: [:id]

      String :created_by, null: false
      String :remarks, text: true
      TrueClass :shipped, default: false
      Integer :credit_note_number, null: true

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:mr_delivery_id], name: :goods_returned_notes_unique_deliveries, unique: true
    end
    run 'CREATE SEQUENCE doc_seqs_credit_note_number;'

    pgt_created_at(:mr_goods_returned_notes,
                   :created_at,
                   function_name: :mr_goods_returned_notes_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:mr_goods_returned_notes,
                   :updated_at,
                   function_name: :mr_goods_returned_notes_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:mr_goods_returned_note_items, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_goods_returned_note_id, :mr_goods_returned_notes, null: false, key: [:id]
      foreign_key :mr_delivery_item_id, :mr_delivery_items, key: [:id]
      foreign_key :mr_delivery_item_batch_id, :mr_delivery_item_batches, key: [:id]

      String :remarks, text: true
      BigDecimal :quantity_returned, size: [12, 2]

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:mr_delivery_item_id], name: :goods_returned_notes_unique_delivery_items, unique: true
      index [:mr_delivery_item_batch_id], name: :goods_returned_notes_unique_delivery_item_batches, unique: true
    end
    pgt_created_at(:mr_goods_returned_note_items,
                   :created_at,
                   function_name: :mr_goods_returned_note_items_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:mr_goods_returned_note_items,
                   :updated_at,
                   function_name: :mr_goods_returned_note_items_set_updated_at,
                   trigger_name: :set_updated_at)

  end

  down do
    run 'DROP SEQUENCE doc_seqs_credit_note_number;'

    drop_trigger(:mr_goods_returned_note_items, :set_created_at)
    drop_function(:mr_goods_returned_note_items_set_created_at)
    drop_trigger(:mr_goods_returned_note_items, :set_updated_at)
    drop_function(:mr_goods_returned_note_items_set_updated_at)
    drop_table(:mr_goods_returned_note_items)

    drop_trigger(:mr_goods_returned_notes, :set_created_at)
    drop_function(:mr_goods_returned_notes_set_created_at)
    drop_trigger(:mr_goods_returned_notes, :set_updated_at)
    drop_function(:mr_goods_returned_notes_set_updated_at)
    drop_table(:mr_goods_returned_notes)
  end
end
