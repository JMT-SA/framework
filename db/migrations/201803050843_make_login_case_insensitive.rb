# Change the login_name column to store its values in a case-insensitive manner.
# This ensures that there are no duplicates with case differences and
# whatever the user types will match without worrying about case differences.

Sequel.migration do
  up do
    run 'CREATE EXTENSION IF NOT EXISTS citext;'
    alter_table(:users) do
      set_column_type :login_name, :citext
    end
  end

  down do
    alter_table(:users) do
      set_column_type :login_name, String
    end
  end
end
