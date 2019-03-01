# require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    alter_table(:location_types) do
      add_column :can_be_moved, :boolean, default: false
    end

    alter_table(:locations) do
      add_column :can_be_moved, :boolean, default: false
    end
  end

  down do
    alter_table(:location_types) do
      drop_column :can_be_moved
    end

    alter_table(:locations) do
      drop_column :can_be_moved
    end
  end
end
