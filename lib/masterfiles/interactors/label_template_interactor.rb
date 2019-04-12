# frozen_string_literal: true

module MasterfilesApp
  class LabelTemplateInteractor < BaseInteractor # rubocop:disable Metrics/ClassLength
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

    def label_variables_from_file(id, params)
      return failed_response('No file selected to import') unless params[:variables] && (tempfile = params[:variables][:tempfile])

      res = variables_from_xml(id, File.read(tempfile))
      return res unless res.success

      store_new_label_variables(id, res.instance)
    end

    def label_variables_from_server(id)
      instance = label_template(id)
      mes_repo = MesserverApp::MesserverRepo.new
      res = mes_repo.label_variables('any', instance.label_template_name)
      return res unless res.success

      res = variables_from_xml(id, res.instance)
      return res unless res.success
      store_new_label_variables(id, res.instance)
    end

    def update_published_templates(params)
      # validate params are as expected
      res = validate_published_labels(params)
      # Log error here unless res.messages.empty?
      return validation_failed_response(res) unless res.messages.empty?

      UpdatePublishedTemplates.call(res)
    end

    private

    def validate_published_labels(params) # rubocop:disable Metrics/AbcSize
      res = LabelTemplatePublishSchema.call(params)
      return res unless res.messages.empty?

      var_errs = {}
      res[:labels].each do |lbl|
        lbl[:variables].each do |var_hash|
          var_hash.each do |var, val|
            inner_res = LabelTemplatePublishInnerSchema.call(val)
            var_errs[var] = inner_res.messages.map { |k, v| "#{k} #{v.join(', ')}" } unless inner_res.messages.empty?
          end
        end
      end

      return OpenStruct.new(messages: var_errs) unless var_errs.empty?
      res
    end

    def store_new_label_variables(id, package)
      repo.transaction do
        repo.update_label_template(id, package)
        log_transaction
        log_status('label_templates', id, 'VARIABLE_LIST_UPDATED')
      end
      instance = label_template(id)
      success_response('Variables stored', instance)
    end

    def variables_from_xml(id, xml_string)
      doc = Nokogiri::XML(xml_string)
      return failed_response('This is not an NSLD label definition') if doc.css('nsld_schema').empty?

      var_list = doc.css('variable_type').map(&:text)
      res = validate_variable_names(label_template(id), var_list)
      return res unless res.success

      success_response('ok', variables: var_list.empty? ? nil : Sequel.pg_array(var_list))
    end

    def validate_variable_names(instance, var_list)
      messages = check_variables(instance, var_list)
      if messages.empty?
        success_response('ok')
      else
        validation_failed_response(OpenStruct.new(messages: { base: messages }))
      end
    rescue Crossbeams::FrameworkError => e
      failed_response(e.message)
    end

    def shared_label_config
      @shared_label_config ||= begin
                                 config_repo = LabelApp::SharedConfigRepo.new
                                 config_repo.packmat_labels_config
                               end
    end

    def check_variables(instance, var_list)
      messages = []
      var_list.each do |varname|
        next if varname.start_with?('CMP:')
        settings = shared_label_config[varname]
        if settings.nil?
          messages << "There is no configuration for variable \"#{varname}\""
        else
          messages << "Variable \"#{varname}\" is not available for application \"#{instance.application}\"" unless settings[:applications].include?(instance.application)
        end
      end
      messages
    end
  end
end
