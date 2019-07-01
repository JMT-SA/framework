# frozen_string_literal: true

module PackMaterialApp
  class MrDeliveryInteractor < BaseInteractor # rubocop:disable Metrics/ClassLength
    def create_mr_delivery(params) # rubocop:disable Metrics/AbcSize
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

    def update_mr_delivery(id, params) # rubocop:disable Metrics/AbcSize
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

    def update_mr_delivery_purchase_invoice(id, params) # rubocop:disable Metrics/AbcSize
      add_invoice = TaskPermissionCheck::MrDelivery.call(:add_invoice, id)
      if add_invoice.success
        res = validate_mr_delivery_purchase_invoice_params(params)
        return validation_failed_response(res) unless res.messages.empty?

        repo.transaction do
          repo.update_mr_delivery(id, res)
          log_transaction
          log_status('mr_deliveries', id, 'PURCHASE INVOICE UPDATED')
        end
        instance = mr_delivery(id)
        success_response("Updated purchase invoice for delivery: #{instance.delivery_number}", instance)
      else
        failed_response(add_invoice.message)
      end
    end

    def accept_mr_delivery_over_supply(id) # rubocop:disable Metrics/AbcSize
      can_accept_over_supply = TaskPermissionCheck::MrDelivery.call(:accept_over_supply, id)
      if can_accept_over_supply.success
        repo.transaction do
          repo.accept_mr_delivery_over_supply(id)
          log_transaction
          log_status('mr_deliveries', id, 'ACCEPTED')
          instance = mr_delivery(id)
          success_response("Accepted Over Supply for delivery #{instance.delivery_number}", instance)
        end
      else
        failed_response(can_accept_over_supply.message)
      end
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def verify_mr_delivery(id) # rubocop:disable Metrics/AbcSize
      can_verify = TaskPermissionCheck::MrDelivery.call(:verify, id)
      if can_verify.success
        repo.transaction do
          repo.verify_mr_delivery(id)
          log_transaction
          log_status('mr_deliveries', id, 'VERIFIED')
          res = PackMaterialApp::CreateDeliverySKUS.call(id, @user.user_name)
          raise Crossbeams::InfoError, res.message unless res.success

          instance = mr_delivery(id)
          success_response("Verified delivery #{instance.delivery_number}", instance)
        end
      else
        failed_response(can_verify.message)
      end
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def complete_invoice(id) # rubocop:disable Metrics/AbcSize
      can_complete_invoice = TaskPermissionCheck::MrDelivery.call(:complete_invoice, id)
      if can_complete_invoice.success
        repo.transaction do
          repo.update_current_prices(id)

          PackMaterialApp::ERPPurchaseInvoiceJob.enqueue(@user.user_name, delivery_id: id)
          log_transaction
          instance = mr_delivery(id)
          success_response("Delivery #{instance.delivery_number}: Purchase Invoice Queued", instance)
        end
      else
        failed_response(can_complete_invoice.message)
      end
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
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

    def putaway_delivery(attrs) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
      delivery_id = repo.delivery_id_from_number(attrs[:delivery_number])
      can_putaway = TaskPermissionCheck::MrDelivery.call(:putaway, delivery_id)
      if can_putaway.success
        res = validate_mr_delivery_putaway_params(attrs)
        return validation_failed_response(res) unless res.messages.empty?

        to_location_id = repo.resolve_location_id_from_scan(attrs[:location], attrs[:location_scan_field])
        return validation_failed_response(location: attrs[:location], messages: { location: ['Location short code not found'] }) unless to_location_id

        sku_ids = repo.sku_ids_from_numbers(attrs[:sku_number])
        sku_id = sku_ids[0]
        qty = Integer(attrs[:quantity])
        to_location_id = Integer(to_location_id)

        bsa_check = TaskPermissionCheck::MrDelivery.call(:bsa_in_progress_check, delivery_id, sku_ids: sku_ids, loc_id: to_location_id)
        if bsa_check.success
          repo.transaction do
            log_transaction
            res1 = PackMaterialApp::MoveMrStock.call(sku_id, to_location_id, qty, user_name: @user.user_name, delivery_id: delivery_id)
            raise Crossbeams::InfoError, res1.message unless res1.success

            res2 = PackMaterialApp::DeliveryPutawayStatusCheck.call(sku_id, qty, delivery_id)
            raise Crossbeams::InfoError, res2.message unless res2.success

            log_status('mr_deliveries', delivery_id, 'PUTAWAY REGISTERED')
            html_report = repo.html_delivery_progress_report(delivery_id, sku_id, to_location_id)
            success_response('Successful putaway', OpenStruct.new(delivery_id: delivery_id, report: html_report))
          end
        else
          failed_response(bsa_check.message)
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

    def del_sub_totals(id)
      repo.del_sub_totals(id)
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

    def validate_mr_delivery_purchase_invoice_params(params)
      MrDeliveryPurchaseInvoiceSchema.call(params)
    end
  end
end
