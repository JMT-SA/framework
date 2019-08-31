Sequel.migration do
  up do
    alter_table(:people) do
      add_index :vat_number, name: :people_unique_vat_number, unique: true
    end

    alter_table(:organizations) do
      add_index :vat_number, name: :organizations_unique_vat_number, unique: true
    end
  end

  down do
    alter_table(:people) do
      drop_index :vat_number, name: :people_unique_vat_number
    end

    alter_table(:organizations) do
      drop_index :vat_number, name: :organizations_unique_vat_number
    end
  end
end
