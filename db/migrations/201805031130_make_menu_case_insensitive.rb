Sequel.migration do
  up do
    run 'CREATE EXTENSION IF NOT EXISTS citext;'
    alter_table(:functional_areas) do
      set_column_type :functional_area_name, :citext
    end
    alter_table(:programs) do
      set_column_type :program_name, :citext
    end
  end

  down do
    alter_table(:functional_areas) do
      set_column_type :functional_area_name, :text
    end
    alter_table(:programs) do
      set_column_type :program_name, :text
    end
  end
end
