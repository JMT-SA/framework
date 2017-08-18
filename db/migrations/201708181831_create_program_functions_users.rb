Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:program_functions_users, ignore_index_errors: true) do
      foreign_key :program_function_id, :program_functions, null: false, key: [:id]
      foreign_key :user_id, :users, null: false, key: [:id]
      
      index [:program_function_id], name: :fki_program_functions_users_prog_func
      index [:user_id], name: :fki_program_functions_users_user
    end
  end

  down do
    drop_table(:program_functions_users)
  end
end
