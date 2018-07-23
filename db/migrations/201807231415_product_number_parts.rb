Sequel.migration do
  up do
    alter_table(:material_resource_domains) do
      add_column :internal_seq, :integer
    end
    run <<~SQL
      UPDATE material_resource_domains m
      SET internal_seq = m2.seqnum
      FROM (SELECT m2.*, ROW_NUMBER() OVER () + 9 AS seqnum
            FROM material_resource_domains m2
           ) m2
      WHERE m2.id = m.id;
    SQL
    alter_table(:material_resource_domains) do
      set_column_not_null :internal_seq
      add_unique_constraint :internal_seq
      add_constraint(:int_seq_min) { internal_seq > 9 }
    end
    alter_table(:material_resource_types) do
      set_column_not_null :short_code
      add_column :internal_seq, :integer
    end
    run <<~SQL
      UPDATE material_resource_types m
      SET internal_seq = m2.seqnum
      FROM (SELECT m2.*, ROW_NUMBER() OVER () AS seqnum
            FROM material_resource_types m2
           ) m2
      WHERE m2.id = m.id;
    SQL
    alter_table(:material_resource_types) do
      set_column_not_null :internal_seq
      add_unique_constraint :internal_seq
    end
    alter_table(:material_resource_sub_types) do
      set_column_not_null :short_code
      add_column :internal_seq, :integer
    end
    run <<~SQL
      UPDATE material_resource_sub_types m
      SET internal_seq = m2.seqnum
      FROM (SELECT m2.*, ROW_NUMBER() OVER () AS seqnum
            FROM material_resource_sub_types m2
           ) m2
      WHERE m2.id = m.id;
    SQL
    alter_table(:material_resource_sub_types) do
      set_column_not_null :short_code
      add_unique_constraint :internal_seq
    end
    alter_table(:pack_material_products) do
      set_column_default :active, false
      set_column_not_null :product_code
      add_unique_constraint :product_code
      rename_column :variety_id, :marketing_variety_id
    end
  end

  down do
    alter_table(:material_resource_domains) do
      drop_column :internal_seq
    end
    alter_table(:material_resource_types) do
      set_column_allow_null :short_code
      drop_column :internal_seq
    end
    alter_table(:material_resource_sub_types) do
      set_column_allow_null :short_code
      drop_column :internal_seq
    end
    alter_table(:pack_material_products) do
      set_column_default :active, nil
      set_column_allow_null :product_code
      drop_unique_constraint :product_code
      rename_column :marketing_variety_id, :variety_id
    end
  end
end
