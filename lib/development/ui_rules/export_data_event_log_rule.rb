# frozen_string_literal: true

module UiRules
  class ExportDataEventLogRule < Base
    def generate_rules
      @repo = DevelopmentApp::ExportDataEventLogRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode
      # set_complete_fields if @mode == :complete
      # set_approve_fields if @mode == :approve

      # add_approve_behaviours if @mode == :approve

      form_name 'export_data_event_log'
    end

    def set_show_fields
      fields[:export_key] = { renderer: :label }
      fields[:started_at] = { renderer: :label, format: :without_timezone_or_seconds }
      fields[:event_log] = { renderer: :label }
      fields[:complete] = { renderer: :label, as_boolean: true }
      fields[:completed_at] = { renderer: :label, format: :without_timezone_or_seconds }
      fields[:failed] = { renderer: :label, as_boolean: true }
      fields[:error_message] = { renderer: :label }
    end

    # def set_approve_fields
    #   set_show_fields
    #   fields[:approve_action] = { renderer: :select, options: [%w[Approve a], %w[Reject r]], required: true }
    #   fields[:reject_reason] = { renderer: :textarea, disabled: true }
    # end

    # def set_complete_fields
    #   set_show_fields
    #   user_repo = DevelopmentApp::UserRepo.new
    #   fields[:to] = { renderer: :select, options: user_repo.email_addresses(user_email_group: AppConst::EMAIL_GROUP_EXPORT_DATA_EVENT_LOG_APPROVERS), caption: 'Email address of person to notify', required: true }
    # end

    def common_fields
      {
        export_key: { required: true },
        started_at: { required: true },
        event_log: {},
        complete: { renderer: :checkbox },
        completed_at: {},
        failed: { renderer: :checkbox },
        error_message: {}
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_export_data_event_log(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(export_key: nil,
                                    started_at: nil,
                                    event_log: nil,
                                    complete: nil,
                                    completed_at: nil,
                                    failed: nil,
                                    error_message: nil)
    end

    # private

    # def add_approve_behaviours
    #   behaviours do |behaviour|
    #     behaviour.enable :reject_reason, when: :approve_action, changes_to: ['r']
    #   end
    # end
  end
end
