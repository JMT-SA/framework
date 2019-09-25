# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class VehicleJob < BaseService
      attr_reader :task, :entity
      def initialize(task, vehicle_job_id = nil)
        @task = task
        @repo = TripsheetsRepo.new
        @id = vehicle_job_id
        @entity = @id ? @repo.find_vehicle_job(@id) : nil
      end

      CHECKS = {
        create: :create_check,
        edit: :edit_check,
        delete: :delete_check,
        can_confirm_arrival: :can_confirm_arrival_check,
        can_load: :can_load_check,
        can_mark_as_loaded: :can_mark_as_loaded_check,
        can_offload: :can_offload_check
      }.freeze

      def call
        return failed_response 'Record not found' unless @entity || task == :create

        check = CHECKS[task]
        raise ArgumentError, "Task \"#{task}\" is unknown for #{self.class}" if check.nil?

        send(check)
      end

      private

      def create_check
        all_ok
      end

      def edit_check
        return failed_response 'Vehicle Job has already been offloaded' if offloaded?

        all_ok
      end

      def update_check
        return failed_response 'Vehicle Job has already been offloaded' if offloaded?
        return failed_response 'Vehicle Job already has loaded units' if already_loaded_units?
        # return failed_response 'Vehicle Job has already been offloaded' if offloaded?

        all_ok
      end

      def delete_check
        return failed_response 'Vehicle Job has already been loaded' if loaded?

        all_ok
      end

      def can_confirm_arrival_check
        return failed_response 'Vehicle Job has no units' if no_units?
        return failed_response 'Vehicle Job units have not been loaded' if not_yet_loaded_units?
        return failed_response 'Vehicle Job has already been offloaded' if offloaded?
        return failed_response 'Vehicle Job does not have a receiving bay set' unless planned_location?
        return failed_response 'Vehicle Job has not yet been marked as loaded' unless loaded?

        all_ok
      end

      def can_load_check
        return failed_response 'Vehicle Job has already been marked as loaded' if loaded?
        return failed_response 'Vehicle Job has no units' if no_units?

        all_ok
      end

      def can_mark_as_loaded_check
        return failed_response 'Vehicle Job has already been marked as loaded' if loaded?
        return failed_response 'Vehicle Job has no units' if no_units?
        return failed_response 'Vehicle Job units have not been loaded' if not_yet_loaded_units?

        all_ok
      end

      def can_offload_check
        return failed_response 'Vehicle Job has not been loaded yet' unless loaded?
        return failed_response 'Vehicle Job has not arrived yet' unless arrival_confirmed? && planned_location?

        all_ok
      end

      def no_units?
        @repo.for_select_vehicle_job_units(where: { vehicle_job_id: @id }).none?
      end

      def not_yet_loaded_units?
        @repo.for_select_vehicle_job_units(where: { vehicle_job_id: @id, loaded: false }).any?
      end

      def already_loaded_units?
        @repo.for_select_vehicle_job_units(where: { vehicle_job_id: @id, loaded: true }).any?
      end

      def planned_location?
        @entity.planned_location_id
      end

      def arrival_confirmed?
        @entity.arrival_confirmed
      end

      def loaded?
        @entity.loaded
      end

      def offloaded?
        @entity.offloaded
      end
    end
  end
end
