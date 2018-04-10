require 'sequel_postgresql_triggers'
Sequel.migration do
  change do
    create_view(:vw_active_users, "SELECT id, login_name, user_name, password_hash, email, active, created_at, updated_at FROM public.users WHERE active;")
  end
end
