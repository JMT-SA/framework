Sequel.migration do
  up do
    create_table(:programs_users, ignore_index_errors: true) do
      primary_key :id
      foreign_key :user_id, :users, null: false, key: [:id]
      foreign_key :program_id, :programs, null: false, key: [:id]
      foreign_key :security_group_id, :security_groups, null: false, key: [:id]
      
      index [:program_id], name: :fki_programs_users_program
      index [:security_group_id], name: :fki_programs_users_security_group
      index [:user_id], name: :fki_programs_users_user
    end
  end

  down do
    drop_table(:programs_users)
  end
end
