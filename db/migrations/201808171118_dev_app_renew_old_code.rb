Sequel.migration do
  up do
    alter_table(:contact_method_types) do
      add_column :active, TrueClass, default: true
    end

    alter_table(:roles) do
      add_unique_constraint :name, name: :roles_name_uniq
    end
  end

  down do
    alter_table(:contact_method_types) do
      drop_column :active
    end

    alter_table(:roles) do
      drop_constraint :roles_name_uniq
    end
  end
end