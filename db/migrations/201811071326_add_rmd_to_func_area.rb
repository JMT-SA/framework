Sequel.migration do
  up do
    add_column :functional_areas, :rmd_menu, :boolean, default: false
  end

  down do
    drop_column :functional_areas, :rmd_menu
  end
end
