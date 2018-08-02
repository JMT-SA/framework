Sequel.migration do
  up do
    root_dir = File.expand_path('..', __dir__)
    sql = File.read(File.join(root_dir, 'ddl', 'functions', 'fn_party_name.sql'))
    run sql

    sql = File.read(File.join(root_dir, 'ddl', 'functions', 'fn_party_role_name.sql'))
    run sql
  end

  down do
    run 'DROP FUNCTION public.fn_party_name(integer);'
    run 'DROP FUNCTION public.fn_party_role_name(integer);'
  end
end
