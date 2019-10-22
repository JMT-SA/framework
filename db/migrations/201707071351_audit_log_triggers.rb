Sequel.migration do
  up do
    root_dir = File.expand_path('..', __dir__)
    sql = File.read(File.join(root_dir, 'ddl', 'triggers', 'audit_logged_actions.sql'))
    run sql
  end

  down do
    run 'DROP FUNCTION audit.audit_table(regclass, boolean, boolean, text[]);'
    run 'DROP FUNCTION audit.audit_table(regclass, boolean, boolean);'
    run 'DROP FUNCTION audit.audit_table(regclass);'
    run 'DROP FUNCTION audit.if_modified_func();'
    run 'DROP TABLE audit.logged_actions;'
    run 'DROP SCHEMA audit;'
  end
end
