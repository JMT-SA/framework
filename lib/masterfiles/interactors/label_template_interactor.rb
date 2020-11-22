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

    def create_label_template(params)
      res = validate_label_template_params(params)
      return validation_failed_response(res) if res.failure?

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
      return validation_failed_response(res) if res.failure?

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

    def label_variables_from_file(id, params)
      return failed_response('No file selected to import') unless params[:variables] && (tempfile = params[:variables][:tempfile])

      UpdateLabelTemplateVariables.call(id, File.read(tempfile), @user)
    end

    def label_variables_from_server(id)
      instance = label_template(id)
      mes_repo = MesserverApp::MesserverRepo.new
      res = mes_repo.label_variables('any', instance.label_template_name)
      return res unless res.success

      UpdateLabelTemplateVariables.call(id, res.instance, @user)
    end

    def update_published_templates(params)
      # validate params are as expected
      res = validate_published_labels(params)
      # Log error here if res.failure?
      return validation_failed_response(res) if res.failure?

      UpdatePublishedTemplates.call(res)
    end

    private

    def validate_published_labels(params) # rubocop:disable Metrics/AbcSize
      res = LabelTemplatePublishSchema.call(params)
      return res if res.failure?
      return res unless matching_variable_set?(res)

      var_errs = {}
      res[:labels].each do |lbl|
        lbl[:variables].each do |var_hash|
          var_hash.each do |var, val|
            inner_res = LabelTemplatePublishInnerSchema.call(val)
            var_errs[var] = inner_res.errors.to_h.map { |k, v| "#{k} #{v.join(', ')}" } if inner_res.failure?
          end
        end
      end

      return OpenStruct.new(messages: var_errs) unless var_errs.empty?

      res
    end

    def matching_variable_set?(res)
      res[:labels].any? { |l| l[:variable_set] == 'Pack Material' }
    end
  end
end
