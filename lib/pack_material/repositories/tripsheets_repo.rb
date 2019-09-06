# frozen_string_literal: true

module PackMaterialApp
  class TripsheetsRepo < BaseRepo
    build_for_select :vehicle_types,
                     label: :type_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :type_code

    crud_calls_for :vehicle_types, name: :vehicle_type, wrapper: VehicleType

    build_for_select :vehicles,
                     label: :vehicle_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :vehicle_code

    crud_calls_for :vehicles, name: :vehicle, wrapper: Vehicle

    build_for_select :vehicle_jobs,
                     label: :tripsheet_number,
                     value: :id,
                     no_active_check: true,
                     order_by: :tripsheet_number

    crud_calls_for :vehicle_jobs, name: :vehicle_job, wrapper: VehicleJob

    build_for_select :vehicle_job_units,
                     label: :id,
                     value: :id,
                     no_active_check: true,
                     order_by: :id

    crud_calls_for :vehicle_job_units, name: :vehicle_job_unit, wrapper: VehicleJobUnit

    def find_vehicle(id)
      find_with_association(:vehicles, id,
                            wrapper: Vehicle,
                            parent_tables: [{ parent_table: :vehicle_types,
                                              foreign_key: :vehicle_type_id,
                                              flatten_columns: { type_code: :type_code } }])
    end

    def find_vehicle_jobs(id)
      find_with_association(:vehicle_jobs, id,
                            wrapper: VehicleJob,
                            parent_tables: [
                              { parent_table: :business_processes, foreign_key: :business_process_id, flatten_columns: { process: :process } },
                              { parent_table: :vehicles, foreign_key: :vehicle_id, flatten_columns: { vehicle_code: :vehicle_code } },
                              { parent_table: :locations, foreign_key: :departure_location_id, flatten_columns: { location_long_code: :location_long_code } }
                            ])
    end

    def vehicle_jobs_business_process_id
      DB[:business_processes].where(process: AppConst::PROCESS_VEHICLE_JOBS).get(:id)
    end
  end
end
