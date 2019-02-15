# frozen_string_literal: true

module PackMaterialApp
  class MrDeliveryInteractor < BaseInteractor
    def create_mr_delivery(params)
      can_create = TaskPermissionCheck::MrDelivery.call(:create)
      if can_create.success
        res = validate_mr_delivery_params(params)
        return validation_failed_response(res) unless res.messages.empty?
        id = nil
        repo.transaction do
          id = repo.create_mr_delivery(res)
          log_status('mr_deliveries', id, 'CREATED')
          log_transaction
        end
        instance = mr_delivery(id)
        success_response("Created delivery #{instance.delivery_number}", instance)
      else
        failed_response(can_create.message)
      end
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { base: ['This delivery already exists'] }))
    end

    def update_mr_delivery(id, params)
      can_update = TaskPermissionCheck::MrDelivery.call(:update, id)
      if can_update.success
        res = validate_mr_delivery_params(params)
        return validation_failed_response(res) unless res.messages.empty?
        repo.transaction do
          repo.update_mr_delivery(id, res)
          log_transaction
        end
        instance = mr_delivery(id)
        success_response("Updated delivery #{instance.delivery_number}", instance)
      else
        failed_response(can_update.message)
      end
    end

    def verify_mr_delivery(id) # rubocop:disable Metrics/AbcSize
      can_verify = TaskPermissionCheck::MrDelivery.call(:verify, id)
      if can_verify.success
        repo.transaction do
          repo.verify_mr_delivery(id)
          log_transaction
          log_status('mr_deliveries', id, 'VERIFIED')
          PackMaterialApp::CreateDeliverySKUS.call(id, @user.user_name)
          instance = mr_delivery(id)
          success_response("Verified delivery #{instance.delivery_number}", instance)
        end
      else
        failed_response(can_verify.message)
      end
    end

    def delete_mr_delivery(id)
      can_delete = TaskPermissionCheck::MrDelivery.call(:delete, id)
      if can_delete.success
        name = mr_delivery(id).delivery_number
        repo.transaction do
          repo.delete_mr_delivery(id)
          log_transaction
          log_status('mr_deliveries', id, 'DELETED')
        end
        success_response("Deleted delivery #{name}")
      else
        failed_response(can_delete.message)
      end
    end

    def putaway_delivery(attrs)
      delivery_id = repo.delivery_id_from_number(attrs[:delivery_number])
      can_putaway = TaskPermissionCheck::MrDelivery.call(:putaway, delivery_id)
      if can_putaway.success
        res = validate_mr_delivery_putaway_params(attrs)
        return validation_failed_response(res) unless res.messages.empty?

        sku_ids = repo.sku_ids_from_numbers(attrs[:sku_number])
        sku_id = sku_ids[0]
        qty = Integer(attrs[:quantity])

        to_location_id = repo.resolve_location_id_from_scan(attrs[:location], attrs[:location_scan_field])
        to_location_id = Integer(to_location_id)

        opts = { user_name: @user.user_name, delivery_id: delivery_id }

        repo.transaction do
          log_transaction
          res1 = PackMaterialApp::MoveMrStock.call(sku_id, to_location_id, qty, opts)
          raise Crossbeams::InfoError, res1.message unless res1.success

          res2 = PackMaterialApp::DeliveryPutawayStatusCheck.call(sku_id, qty, delivery_id)
          raise Crossbeams::InfoError, res2.message unless res2.success

          log_status('mr_deliveries', delivery_id, 'PUTAWAY REGISTERED')
          html_report = repo.html_delivery_progress_report(delivery_id, sku_id, to_location_id)
          success_response('Successful putaway', OpenStruct.new(delivery_id: delivery_id, report: html_report))
        end
      else
        failed_response(can_putaway.message)
      end
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def html_progress_report(delivery_id, sku_id, to_location_id)
      repo.html_delivery_progress_report(delivery_id, sku_id, to_location_id)
    end

    private

    def repo
      @repo ||= ReplenishRepo.new
    end

    def mr_delivery(id)
      repo.find_mr_delivery(id)
    end

    def validate_mr_delivery_params(params)
      MrDeliverySchema.call(params)
    end

    def validate_mr_delivery_putaway_params(params)
      MrDeliveryPutawaySchema.call(params)
    end
  end
end
