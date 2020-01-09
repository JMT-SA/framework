Sequel.migration do
  up do
    alter_table(:destination_countries) do
      add_column :iso_country_code, String
    end
  end

  down do
    alter_table(:destination_countries) do
      drop_column :iso_country_code
    end
  end
end
