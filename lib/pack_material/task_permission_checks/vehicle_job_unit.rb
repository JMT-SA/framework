# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class VehicleJobUnit < BaseService
      attr_reader :task, :entity
      def initialize(task, vehicle_job_unit_id = nil)
        @task = task
        @repo = TripsheetsRepo.new
        @id = vehicle_job_unit_id
        @entity = @id ? @repo.find_vehicle_job_unit(@id) : nil
      end

      CHECKS = {
        create: :create_check,
        update: :update_check,
        load: :load_check,
        delete: :delete_check
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

      def delete_check
        return failed_response 'Vehicle Job Unit has already been loaded' if loaded?
        return failed_response 'Vehicle Job Unit is already loading' if when_loading?

        all_ok
      end

      def update_check
        return failed_response 'Vehicle Job Unit has already been loaded' if loaded?
        return failed_response 'Vehicle Job Unit is already loading' if when_loading?

        all_ok
      end

      def load_check
        return failed_response 'Vehicle Job Unit quantity to move is zero' unless qty_to_move_positive
        return failed_response 'Vehicle Job Unit has already been loaded' if loaded?

        all_ok
      end

      def loaded?
        @entity.loaded
      end

      def when_loading?
        !@entity.when_loading.nil?
      end

      def qty_to_move_positive
        @entity.quantity_to_move&.positive?
      end
    end
  end
end
