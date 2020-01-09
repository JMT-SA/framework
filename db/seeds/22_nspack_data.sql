-- PM TYPE
INSERT INTO pm_types (pm_type_code, description) VALUES ('BIN', 'BIN');
INSERT INTO pm_types (pm_type_code, description) VALUES ('CARTON', 'CARTON');

-- PORT_TYPES
INSERT INTO port_types (port_type_code, description) VALUES('POL', 'Port of Loading');
INSERT INTO port_types (port_type_code, description) VALUES('POD', 'Port of Dispatch');
INSERT INTO port_types (port_type_code, description) VALUES('TRANSSHIP', 'Transfer Shipment');

-- ROLES
INSERT INTO roles (name) VALUES ('MARKETER');
INSERT INTO roles (name) VALUES ('SHIPPING_LINE');
INSERT INTO roles (name) VALUES ('SHIPPER');
INSERT INTO roles (name) VALUES ('FINAL_RECEIVER');
INSERT INTO roles (name) VALUES ('EXPORTER');
INSERT INTO roles (name) VALUES ('BILLING_CLIENT');
INSERT INTO roles (name) VALUES ('CONSIGNEE');
INSERT INTO roles (name) VALUES ('HAULIER');
INSERT INTO roles (name) VALUES ('FARM_OWNER');
INSERT INTO roles (name) VALUES ('INSPECTOR');
INSERT INTO roles (name) VALUES ('INSPECTION_BILLING');

-- TARGET MARKET GROUP TYPES
INSERT INTO target_market_group_types (target_market_group_type_code) VALUES('PACKED');
INSERT INTO target_market_group_types (target_market_group_type_code) VALUES('SHIPPING');
INSERT INTO target_market_group_types (target_market_group_type_code) VALUES('MARKETING');
INSERT INTO target_market_group_types (target_market_group_type_code) VALUES('SALES');

-- VOYAGE_TYPES
INSERT INTO voyage_types (voyage_type_code, description) VALUES('ROAD', 'Trucks');
INSERT INTO voyage_types (voyage_type_code, description) VALUES('AIR', 'Air');
INSERT INTO voyage_types (voyage_type_code, description) VALUES('SEA', 'Sea');
INSERT INTO voyage_types (voyage_type_code, description) VALUES('RAIL', 'Rail');

-- VESSEL_TYPES
INSERT INTO vessel_types (voyage_type_id, vessel_type_code, description) VALUES((SELECT id FROM voyage_types WHERE voyage_type_code = 'ROAD'), 'TRUCK', 'Truck');
INSERT INTO vessel_types (voyage_type_id, vessel_type_code, description) VALUES((SELECT id FROM voyage_types WHERE voyage_type_code = 'SEA'), 'SHIP', 'Ship');
INSERT INTO vessel_types (voyage_type_id, vessel_type_code, description) VALUES((SELECT id FROM voyage_types WHERE voyage_type_code = 'RAIL'), 'TRAIN', 'Train');
INSERT INTO vessel_types (voyage_type_id, vessel_type_code, description) VALUES((SELECT id FROM voyage_types WHERE voyage_type_code = 'AIR'), 'AIRCRAFT', 'Aircraft');

-- CONTAINER_STACK_TYPES
INSERT INTO container_stack_types (stack_type_code, description) VALUES('S', 'Standard');
INSERT INTO container_stack_types (stack_type_code, description) VALUES('H', 'High');

-- REWORKS_RUN_TYPES
INSERT INTO reworks_run_types (run_type, description) VALUES('SINGLE PALLET EDIT', 'Single pallet edit');
INSERT INTO reworks_run_types (run_type, description) VALUES('BATCH PALLET EDIT', 'Batch pallet edit');
INSERT INTO reworks_run_types (run_type, description) VALUES('SCRAP PALLET', 'Scrap Pallet');
INSERT INTO reworks_run_types (run_type, description) VALUES('UNSCRAP PALLET', 'Unscrap Pallet');
INSERT INTO reworks_run_types (run_type, description) VALUES('REPACK PALLET', 'Repack Pallet');
INSERT INTO reworks_run_types (run_type, description) VALUES('BUILDUP', 'Buildup');
INSERT INTO reworks_run_types (run_type, description) VALUES('TIP BINS', 'Tip Bins');
INSERT INTO reworks_run_types (run_type, description) VALUES('WEIGH RMT BINS', 'Weigh Rmt Bins');

-- IN-TRANSIT LOCATION (Not part of locations tree)
INSERT INTO location_types (location_type_code, short_code) VALUES('IN_TRANSIT', 'IN_TRANSIT') ON CONFLICT DO NOTHING;
INSERT INTO location_storage_types (storage_type_code) VALUES('PALLETS') ON CONFLICT DO NOTHING;
INSERT INTO location_assignments (assignment_code) VALUES('TRANSIT') ON CONFLICT DO NOTHING;
INSERT INTO locations (primary_storage_type_id, location_type_id, primary_assignment_id, location_long_code, location_description, location_short_code, can_be_moved, can_store_stock)
VALUES ((SELECT id FROM location_storage_types WHERE storage_type_code = 'PALLETS'), (SELECT id FROM location_types WHERE location_type_code = 'IN_TRANSIT'), (SELECT id FROM location_assignments WHERE assignment_code = 'TRANSIT'), 'IN_TRANSIT_EX_PACKHSE', 'IN_TRANSIT_EX_PACKHSE', 'IN_TRANSIT_EX_PACKHSE', true, true);

-- BUSINESS PROCESSES
INSERT INTO business_processes(process, description) VALUES('MOVE_PALLET', 'ADHOC individual FG Pallet movements');
INSERT INTO business_processes(process, description) VALUES('LOAD_SHIPPED', 'Load truck pallets shipped');

-- STOCK TYPES
INSERT INTO stock_types(stock_type_code, description) VALUES('PALLET', 'FG PALLETS');

INSERT INTO inspection_failure_types (failure_type_code) VALUES('GOVERNMENT');
