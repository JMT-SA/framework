# require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  change do
    # Example for create table:
    # create_table(:table_name, ignore_index_errors: true) do
    #   primary_key :id
    #   foreign_key :some_id, :some_table_name, null: false, key: [:id]
    #
    #   String :my_uniq_name, size: 255, null: false
    #   String :user_name, size: 255
    #   String :password_hash, size: 255, null: false
    #   String :email, size: 255
    #   TrueClass :active, default: true
    #   DateTime :created_at, null: false
    #   DateTime :updated_at, null: false
    #
    #   index [:some_id], name: :fki_table_name_some_table_name
    #   index [:my_uniq_name], name: :table_name_unique_my_uniq_name, unique: true
    # end
  end
  # Example for setting up created_at and updated_at timestamp triggers:
  # (Change table_name to the actual table name).
  # up do
  #   extension :pg_triggers

  #   pgt_created_at(:table_name,
  #                  :created_at,
  #                  function_name: :table_name_set_created_at,
  #                  trigger_name: :set_created_at)

  #   pgt_updated_at(:table_name,
  #                  :updated_at,
  #                  function_name: :table_name_set_updated_at,
  #                  trigger_name: :set_updated_at)
  # end

  # down do
  #   drop_trigger(:table_name, :set_created_at)
  #   drop_function(:table_name_set_created_at)
  #   drop_trigger(:table_name, :set_updated_at)
  #   drop_function(:table_name_set_updated_at)
  # end
end
