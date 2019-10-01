# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

module PackMaterialApp
  module TaskPermissionCheck
    class VehicleJob < BaseService
      attr_reader :task, :entity
      def initialize(task, vehicle_job_id = nil, current_user = nil)
        @task = task
        @repo = TripsheetsRepo.new
        @id = vehicle_job_id
        @entity = @id ? @repo.find_vehicle_job(@id) : nil
        @user = current_user
      end

      CHECKS = {
        create: :create_check,
        edit: :create_check,
        edit_header: :edit_header_check,
        delete: :delete_check,
        update: :update_check,
        can_set_planned_loc: :can_set_planned_loc_check,
        can_confirm_arrival: :can_confirm_arrival_check,
        confirm_arrival: :confirm_arrival_check,
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

      def edit_header_check
        return failed_response 'Vehicle Job has already been offloaded' if offloaded?
        return failed_response 'Vehicle Job is loaded' if loaded?
        return failed_response 'Vehicle Job is loading' if when_loading?

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

      def can_set_planned_loc_check
        return failed_response 'Vehicle Job is already being offloaded' if when_offloading?

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
        return failed_response 'Vehicle Job has not arrived yet' if planned_location? && !arrival_confirmed?

        all_ok
      end

      def confirm_arrival_check
        return failed_response 'User is not allowed to confirm arrival of Vehicle Jobs' unless can_user_confirm_arrival?

        all_ok
      end

      def can_user_confirm_arrival?
        Crossbeams::Config::UserPermissions.can_user?(@user, :tripsheets, :confirm_arrival)
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

      def when_loading?
        @entity.when_loading
      end

      def when_offloading?
        @entity.when_offloading
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
