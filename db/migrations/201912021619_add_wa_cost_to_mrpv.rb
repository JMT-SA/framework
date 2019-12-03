require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    alter_table(:material_resource_product_variants) do
      add_column :weighted_average_cost, BigDecimal, size: [15, 5]
      add_column :wa_cost_updated_at, DateTime
    end

    run <<~SQL
      -- ==========================================================================
      -- Set timestamp of the latest update to weighted_average_cost
      -- ==========================================================================
      CREATE OR REPLACE FUNCTION public.fn_set_wa_cost_timestamp()
        RETURNS trigger AS
      $BODY$
        BEGIN
          IF (NEW.weighted_average_cost IS NOT NULL) THEN
            NEW.wa_cost_updated_at = current_timestamp;
          END IF;

          RETURN NEW;
        END
      $BODY$
        LANGUAGE plpgsql VOLATILE
        COST 100;
      ALTER FUNCTION public.fn_set_wa_cost_timestamp()
        OWNER TO postgres;
    
      CREATE TRIGGER set_wa_cost_timestamp_trigger
      BEFORE INSERT OR UPDATE OF weighted_average_cost
      ON public.material_resource_product_variants
      FOR EACH ROW
      EXECUTE PROCEDURE fn_set_wa_cost_timestamp();
    SQL
  end

  down do
    run <<~SQL
      DROP TRIGGER set_wa_cost_timestamp_trigger ON material_resource_product_variants;
      DROP FUNCTION public.fn_set_wa_cost_timestamp();
    SQL

    alter_table(:material_resource_product_variants) do
      drop_column :weighted_average_cost
      drop_column :wa_cost_updated_at
    end
  end
end



