module MiniTestSeeds
  def db_create_processes
    # processes
    @fixed_table_set[:processes] = { delivery_process_id: DB[:business_processes].insert(process: AppConst::PROCESS_DELIVERIES),
                                     vehicle_job_process_id: DB[:business_processes].insert(process: AppConst::PROCESS_VEHICLE_JOBS),
                                     adhoc_transactions_process_id: DB[:business_processes].insert(process: AppConst::PROCESS_ADHOC_TRANSACTIONS),
                                     bulk_stock_adjustments_process_id: DB[:business_processes].insert(process: AppConst::PROCESS_BULK_STOCK_ADJUSTMENTS)
    }
  end

  def db_create_roles
    # roles
    cus_id = DB[:roles].insert(name: AppConst::ROLE_CUSTOMER)
    sup_id = DB[:roles].insert(name: AppConst::ROLE_SUPPLIER)
    mar_id = DB[:roles].insert(name: 'MARKETER')
    ret_id = DB[:roles].insert(name: 'RETAILER')
    @fixed_table_set[:roles] = { customer: { id: cus_id },
                                 supplier: { id: sup_id },
                                 marketer: { id: mar_id },
                                 retailer: { id: ret_id }
    }
  end

  def db_create_packmat_seeds
    # domain
    dom_id = DB[:material_resource_domains].insert(
      domain_name: PackMaterialApp::DOMAIN_NAME,
      product_table_name: 'pack_material_products',
      variant_table_name: 'pack_material_product_variants'
    )
    @fixed_table_set[:domain_id] = dom_id

    # product columns
    DB[prod_col_sql].insert

    # mr type
    mr_type_id = DB[:material_resource_types].insert(
      material_resource_domain_id: dom_id,
      internal_seq: 1,
      type_name: 'PM SC Type',
      short_code: 'SC',
      description: 'This is the description field'
    )
    @fixed_table_set[:matres_types] = { sc: { id: mr_type_id, short_code: 'SC' } }

    # Units of Measure
    uom_type_id = DB[:uom_types].insert(code: 'PM')
    @fixed_table_set[:uoms] = {
      uom_type_id: uom_type_id,
      uom_id: DB[:uoms].insert(uom_type_id: uom_type_id, uom_code: 'kg')
    }

    # mr sub
    sql = <<~SQL
      SELECT id FROM material_resource_product_columns
      WHERE column_name IN ('unit', 'style', 'brand_1')
    SQL
    prod_code_ids = DB[sql].select_map
    sql = <<~SQL
      SELECT id FROM material_resource_product_columns
      WHERE column_name IN ('unit', 'style', 'brand_1', 'reference_size', 'reference_dimension', 'reference_quantity')
    SQL
    prod_col_ids = DB[sql].select_map
    sub_id = DB[:material_resource_sub_types].insert(
      material_resource_type_id: mr_type_id,
      internal_seq: 1,
      inventory_uom_id: @fixed_table_set[:uoms][:uom_id],
      sub_type_name: 'PM SC Sub Type',
      short_code: 'SC',
      product_code_ids: "{#{prod_code_ids.join(',')}}",
      product_column_ids: "{#{prod_col_ids.join(',')}}"
    )
    @fixed_table_set[:matres_sub_types] = { sc: { id: sub_id, short_code: 'SC', prod_code_ids: prod_code_ids } }

    # commodities

    # mkt varieties
  end

  def prod_col_sql
    <<~SQL
      INSERT INTO material_resource_product_columns (material_resource_domain_id, column_name, short_code, description)
        SELECT dom.id, sub.column_name, sub.short_code, sub.description
        FROM material_resource_domains dom
          JOIN (SELECT * FROM (VALUES ('unit', 'UNIT', 'Unit', 1),
            ('style', 'STYL', 'Style', 1),
            ('alternate', 'ALTE', 'Alternate', 1),
            ('shape', 'SHPE', 'Shape', 1),
            ('reference_size', 'REFS', 'Reference Size', 1),
            ('reference_dimension', 'REFD', 'Reference Dimension', 1),
            ('reference_quantity', 'REFQ', 'Reference Quantity', 1),
            ('brand_1', 'BRD1', 'Brand1', 1),
            ('brand_2', 'BRD2', 'Brand2', 1),
            ('colour', 'COLR', 'Colour', 1),
            ('material', 'MATR', 'Material', 1),
            ('assembly', 'ASSM', 'Assembly', 1),
            ('reference_mass', 'REFM', 'Reference Mass', 1),
            ('reference_number', 'REFN', 'Reference Number', 1),
            ('market', 'MRKT', 'Market', 1),
            ('marking', 'MARK', 'Marking', 1),
            ('model', 'MODL', 'Model', 1),
            ('pm_class', 'CLAS', 'Class', 1),
            ('grade', 'GRAD', 'Grade', 1),
            ('language', 'LANG', 'Language', 1),
            ('other', 'OTHR', 'Other', 1),
            ('commodity_id', 'COMM', 'Commodity', 1),
            ('marketing_variety_id', 'VARY', 'Variety', 1))
            AS t(column_name, short_code, description, n)) sub ON sub.n = 1
        WHERE dom.domain_name = 'Pack Material';
    SQL
  end

  def db_create_locations
    assignment_id = DB[:location_assignments].insert(assignment_code: 'Assignment Code')
    storage_type_id = DB[:location_storage_types].insert(storage_type_code: PackMaterialApp::DOMAIN_NAME)
    location_type_id = DB[:location_types].insert(location_type_code: 'RECEIVING BAY', short_code: 'RB')
    default_id = DB[:locations].insert(
      primary_storage_type_id: storage_type_id,
      location_type_id: location_type_id,
      primary_assignment_id: assignment_id,
      location_description: 'Default Receiving Bay',
      location_long_code: 'RECEIVING BAY',
      location_short_code: 'RBY'
    )
    @fixed_table_set[:locations] = {
      assignment_id: assignment_id,
      storage_type_id: storage_type_id,
      type_id: location_type_id,
      default_id: default_id
    }
  end

  def db_create_inventory_transaction_types
    remove_id = DB[:mr_inventory_transaction_types].insert(type_name: 'REMOVE STOCK')
    create_id = DB[:mr_inventory_transaction_types].insert(type_name: 'CREATE STOCK')
    putaway_id = DB[:mr_inventory_transaction_types].insert(type_name: 'PUTAWAY')
    adhoc_id = DB[:mr_inventory_transaction_types].insert(type_name: 'ADHOC MOVE')
    @fixed_table_set[:inventory_transaction_types] = {
      create_stock_id: create_id,
      putaway_id: putaway_id,
      adhoc_move_id: adhoc_id,
      remove_stock_id: remove_id
    }
  end
end
