Sequel.migration do
  up do
    alter_table(Sequel[:audit][:logged_action_details]) do
      add_column :request_ip, String
    end
  end

  down do
    alter_table(Sequel[:audit][:logged_action_details]) do
      drop_column :request_ip
    end
  end
end
