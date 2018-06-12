# frozen_string_literal: true

module UiRules
  class PreparedReportRule < Base
    def generate_rules
      @user_repo = DevelopmentApp::UserRepo.new
      @prep_repo = DataminerApp::PreparedReportRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields case @mode
                               when :webquery
                                 webquery_fields
                               when :edit
                                 edit_fields
                               when :new
                                 new_fields
                               when :properties
                                 properties_fields
                               when :change_columns
                                 column_fields
                               end

      form_name 'prepared_report'
    end

    def new_fields
      {
        database: { readonly: true },
        report_template: { readonly: true },
        report_description: { required: true },
        id: { renderer: :hidden },
        json_var: { renderer: :hidden },
        existing_report: { renderer: :select,
                           caption: 'Overwrite an existing report',
                           options: @prep_repo.existing_prepared_reports_for(@options[:id], @options[:user]),
                           prompt: 'Leave blank to save a new report or choose one to replace...' }
      }
    end

    def edit_fields
      {
        database: { readonly: true },
        report_template: { readonly: true },
        report_description: { required: true },
        id: { renderer: :label, caption: 'Report id' },
        linked_users: { renderer: :multi, options: @user_repo.for_select_users, selected: @form_object.selected_users || [] }
      }
    end

    def webquery_fields
      {
        webquery_url: { readonly: true, copy_to_clipboard: true }
      }
    end

    def properties_fields
      {
        database: { readonly: true },
        report_template: { readonly: true },
        report_description: { renderer: :label },
        id: { renderer: :label, caption: 'Report id' },
        webquery_url: { readonly: true, copy_to_clipboard: true },
        param_description: { renderer: :list, items: @options[:instance][:param_texts], caption: 'Parameters applied' }
      }
    end

    def column_fields
      {
        report_description: { renderer: :label },
        column_sequence: { renderer: :sortable_list, caption: 'Column order', prefix: 'co' },
        hidden_columns: { renderer: :sortable_list, caption: 'Hidden columns', prefix: 'hc' }
      }
    end

    def make_form_object
      @form_object = if @mode == :edit
                       read_form_object
                     elsif @mode == :change_columns
                       columns_form_object
                     else
                       @options[:instance] ? form_instance_object : form_new_object
                     end
    end

    def read_form_object
      rpt = DataminerApp::PreparedReportRepo.new.lookup_report(@options[:id])
      OpenStruct.new(id: @options[:id],
                     report_description: rpt.caption,
                     selected_users: rpt.external_settings[:prepared_report][:linked_users])
    end

    def form_new_object
      OpenStruct.new(id: @options[:id],
                     database: @options[:id].split('_').first,
                     report_template: @options[:id].split('_').last,
                     json_var: @options[:json_var],
                     report_description: nil)
    end

    def form_instance_object
      OpenStruct.new(id: @options[:instance][:id],
                     report_description: @options[:instance][:report_description],
                     webquery_url: @options[:url],
                     param_description: @options[:instance][:param_texts])
    end

    def columns_form_object
      OpenStruct.new(report_description: @options[:instance][:report_description])
    end
  end
end
