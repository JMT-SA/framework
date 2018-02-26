require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    create_table(:programs_webapps, ignore_index_errors: true) do
      foreign_key :program_id, :programs, null: false, key: [:id]
      String :webapp, null: false

      primary_key [:program_id, :webapp], name: :programs_webapps_pk
    end
  end

  down do
    drop_table(:programs_webapps)
  end
end
