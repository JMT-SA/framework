# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

module MasterfilesApp
  class LocationInteractor < BaseInteractor
    def create_location_type(params)
      res = validate_location_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_location_type(res)
        log_transaction
      end
      instance = location_type(id)
      success_response("Created location type #{instance.location_type_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { location_type_code: ['This location type already exists'] }))
    end

    def update_location_type(id, params)
      res = validate_location_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_location_type(id, res)
        log_transaction
      end
      instance = location_type(id)
      success_response("Updated location type #{instance.location_type_code}", instance)
    end

    def delete_location_type(id)
      name = location_type(id).location_type_code
      repo.transaction do
        repo.delete_location_type(id)
        log_transaction
      end
      success_response("Deleted location type #{name}")
    end

    def create_root_location(params)
      res = validate_location_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_root_location(res)
        log_transaction
      end
      instance = location(id)
      success_response("Created location #{instance.location_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { location_code: ['This location already exists'] }))
    end

    def create_location(parent_id, params)
      res = validate_location_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_child_location(parent_id, res)
        log_transaction
      end
      instance = location(id)
      success_response("Created location #{instance.location_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { location_code: ['This location already exists'] }))
    end

    def update_location(id, params)
      res = validate_location_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_location(id, res)
        log_transaction
      end
      instance = location(id)
      success_response("Updated location #{instance.location_code}", instance)
    end

    def delete_location(id)
      return failed_response('Cannot delete this location - it has sub-locations') if repo.location_has_children(id)
      name = location(id).location_code
      repo.transaction do
        repo.delete_location(id)
        log_transaction
      end
      success_response("Deleted location #{name}")
    end

    def create_location_assignment(params)
      res = validate_location_assignment_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_location_assignment(res)
        log_transaction
      end
      instance = location_assignment(id)
      success_response("Created location assignment #{instance.assignment_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { assignment_code: ['This location assignment already exists'] }))
    end

    def update_location_assignment(id, params)
      res = validate_location_assignment_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_location_assignment(id, res)
        log_transaction
      end
      instance = location_assignment(id)
      success_response("Updated location assignment #{instance.assignment_code}", instance)
    end

    def delete_location_assignment(id)
      name = location_assignment(id).assignment_code
      repo.transaction do
        repo.delete_location_assignment(id)
        log_transaction
      end
      success_response("Deleted location assignment #{name}")
    end

    def create_location_storage_type(params)
      res = validate_location_storage_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_location_storage_type(res)
        log_transaction
      end
      instance = location_storage_type(id)
      success_response("Created location storage type #{instance.storage_type_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { storage_type_code: ['This location storage type already exists'] }))
    end

    def update_location_storage_type(id, params)
      res = validate_location_storage_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_location_storage_type(id, res)
        log_transaction
      end
      instance = location_storage_type(id)
      success_response("Updated location storage type #{instance.storage_type_code}", instance)
    end

    def delete_location_storage_type(id)
      name = location_storage_type(id).storage_type_code
      repo.transaction do
        repo.delete_location_storage_type(id)
        log_transaction
      end
      success_response("Deleted location storage type #{name}")
    end

    def link_assignments(id, multiselect_ids)
      res = nil
      repo.transaction do
        res = repo.link_assignments(id, multiselect_ids)
      end
      return res unless res.success
      success_response('Assignments linked successfully')
    end

    def link_storage_types(id, multiselect_ids)
      res = nil
      repo.transaction do
        res = repo.link_storage_types(id, multiselect_ids)
      end
      return res unless res.success
      success_response('Storage types linked successfully')
    end

    def location_code_suggestion(parent_id, location_type_id)
      res = repo.location_code_suggestion(parent_id, location_type_id)
      return res unless res.success
      success_response('See location code suggestion', res.instance)
    end

    def print_location_barcode(id, params)
      instance = location(id)
      # NOTE: we don't know for sure that F1 will be code and F2 will be desc...
      #       - so we need to get those position/variable links from the label...
      #       - ALSO: LD needs to change to allow for different variable sets...

      # This is an approximation of something we might get from the label variables:
      lbl_required = [{ f_no: 1, field: 'location_barcode' }, # This is a field used in the label, not the table...
                      { f_no: 2, field: 'location_description' },
                      { f_no: 3, field: 'location_code' },
                      { f_no: 4, field: 'legacy_barcode' }]
      vars = {}
      bcp = BarcodeProcessing.new
      lbl_required.each do |var|
        vars["F#{var[:f_no]}".to_sym] = if barcode_field?(instance, var[:field])
                                          bcp.make_barcode(instance, var[:field].delete_suffix('_barcode'))
                                        else
                                          instance[var[:field].to_sym]
                                        end
      end
      mes_repo = MesserverApp::MesserverRepo.new
      printer = repo.find_hash(:printers, params[:printer])
      mes_repo.print_label(AppConst::LABEL_LOCATION_BARCODE, vars, params[:quantity], printer[:printer_code])
    end

    private

    def repo
      @repo ||= LocationRepo.new
    end

    def location_type(id)
      repo.find_location_type(id)
    end

    def validate_location_type_params(params)
      LocationTypeSchema.call(params)
    end

    def location(id)
      repo.find_location(id)
    end

    def validate_location_params(params)
      LocationSchema.call(params)
    end

    def location_assignment(id)
      repo.find_location_assignment(id)
    end

    def validate_location_assignment_params(params)
      LocationAssignmentSchema.call(params)
    end

    def location_storage_type(id)
      repo.find_location_storage_type(id)
    end

    def validate_location_storage_type_params(params)
      LocationStorageTypeSchema.call(params)
    end

    def barcode_field?(instance, field)
      field.end_with?('_barcode') && !instance.key?(field)
    end
  end
end
# rubocop:enable Metrics/ClassLength
