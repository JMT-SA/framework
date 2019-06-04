# frozen_string_literal: true

module UiRules
  class QueJobRule < Base
    def generate_rules
      @repo = DevelopmentApp::QueJobRepo.new
      make_form_object
      apply_form_values

      set_show_fields if @mode == :show
      set_status_fields if @mode == :status

      form_name 'que_job'
    end

    def set_show_fields # rubocop:disable Metrics/AbcSize
      fields[:priority] = { renderer: :label }
      fields[:run_at] = { renderer: :label }
      fields[:job_class] = { renderer: :label }
      fields[:error_count] = { renderer: :label }
      fields[:last_error_message] = { renderer: :label }
      fields[:queue] = { renderer: :label }
      fields[:last_error_backtrace] = { renderer: :label }
      fields[:finished_at] = { renderer: :label }
      fields[:expired_at] = { renderer: :label }
      fields[:args] = { renderer: :label }
      fields[:data] = { renderer: :label }
    end

    def set_status_fields
      res = @repo.que_status
      rules[:headers] = %i[job_class count count_working count_errored highest_error_count oldest_run_at]
      rules[:details] = res
      rules[:alignment] = { count: :right, count_working: :right, count_errored: :right, highest_error_count: :right }
    end

    def make_form_object
      make_new_form_object && return if @mode == :status

      @form_object = @repo.find_que_job(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(priority: 100,
                                    run_at: nil,
                                    job_class: nil,
                                    error_count: 0,
                                    last_error_message: nil,
                                    queue: 'default',
                                    last_error_backtrace: nil,
                                    finished_at: nil,
                                    expired_at: nil,
                                    args: nil,
                                    data: nil)
    end
  end
end
