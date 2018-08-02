Sequel.migration do
  up do
    root_dir = File.expand_path('..', __dir__)
    sql = File.read(File.join(root_dir, 'ddl', 'functions', 'fn_formatted_product_variant_number.sql'))
    run sql

    sql = File.read(File.join(root_dir, 'ddl', 'functions', 'fn_formatted_product_number.sql'))
    run sql
  end

  down do
    run 'DROP FUNCTION public.fn_formatted_product_number(integer);'
    run 'DROP FUNCTION public.fn_formatted_product_variant_number(bigint);'
  end
end
