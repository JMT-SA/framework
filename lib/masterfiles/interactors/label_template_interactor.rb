# frozen_string_literal: true

module MasterfilesApp
  class LabelTemplateInteractor < BaseInteractor
    def repo
      @repo ||= LabelTemplateRepo.new
    end

    def label_template(id)
      repo.find_label_template(id)
    end

    def validate_label_template_params(params)
      LabelTemplateSchema.call(params)
    end

    def create_label_template(params) # rubocop:disable Metrics/AbcSize
      res = validate_label_template_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_label_template(res)
        log_status('label_templates', id, 'CREATED')
        log_transaction
      end
      instance = label_template(id)
      success_response("Created label template #{instance.label_template_name}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { label_template_name: ['This label template already exists'] }))
    end

    def update_label_template(id, params)
      res = validate_label_template_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_label_template(id, res)
        log_transaction
      end
      instance = label_template(id)
      success_response("Updated label template #{instance.label_template_name}",
                       instance)
    end

    def delete_label_template(id)
      name = label_template(id).label_template_name
      repo.transaction do
        repo.delete_label_template(id)
        log_status('label_templates', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted label template #{name}")
    end

    def get_variables(id, params) # rubocop:disable Metrics/AbcSize
      return failed_response('No file selected to import') unless params[:variables] && (tempfile = params[:variables][:tempfile])

      doc = Nokogiri::XML(File.read(tempfile))
      return failed_response('This is not an NSLD label definition') if doc.css('nsld_schema').empty?

      var_list = doc.css('variable_type').map(&:text)
      package = { variables: var_list.empty? ? nil : Sequel.pg_array(var_list) }

      repo.transaction do
        repo.update_label_template(id, package)
        log_transaction
        log_status('label_templates', id, 'VARIABLE_LIST_UPDATED')
      end
      instance = label_template(id)
      success_response('Variables stored', instance)
    end
  end
end
