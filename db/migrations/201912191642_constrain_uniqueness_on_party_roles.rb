Sequel.migration do
  up do
    alter_table(:party_roles) do
      add_unique_constraint [:party_id, :role_id], name: :party_role_uniq
    end
  end

  down do
    alter_table(:party_roles) do
      drop_constraint :party_role_uniq
    end
  end
end
