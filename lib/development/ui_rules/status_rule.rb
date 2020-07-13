# frozen_string_literal: true

module UiRules
  class StatusRule < Base
    def generate_rules # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      @dev_repo = DevelopmentApp::DevelopmentRepo.new
      @repo = DevelopmentApp::StatusRepo.new
      make_form_object

      common_values_for_fields select_fields

      set_show_fields if @mode == :show
      set_detail_fields if @mode == :detail
      rules[:rows] = [@form_object.to_h] if @mode == :show || @mode == :detail

      if @mode == :list
        header_def = Crossbeams::Config::StatusHeaderDefinitions::HEADER_DEF[@options[:table_name].to_sym]
        unless header_def.nil?
          query = header_def[:query]
          rules[:detail_cols], rules[:detail_rows] = @repo.cols_and_rows_from_query(query, @options[:id])
          rules[:detail_caption] = header_def[:caption]
          rules[:detail_headers] = header_def[:headers]
        end

        rules[:cols] = %i[detail diff action_time status user_name]
        rules[:header_captions] = { action_time: 'Time', row_data_id: 'ID' }
        rules[:rows] = @repo.list_statuses(@options[:table_name], @options[:id]).map do |rec|
          { id: rec[:id], action_time: rec[:action_time].strftime('%Y-%m-%d %H:%M:%S'), status: rec[:status], user_name: rec[:user_name],
            detail: Crossbeams::Layout::Link.new(text: 'view',
                                                 url: "/development/statuses/detail/#{rec[:id]}",
                                                 behaviour: :popup,
                                                 style: :small_button).render,
            diff: Crossbeams::Layout::Link.new(text: 'view',
                                               url: "/development/statuses/diff/#{rec[:id]}",
                                               behaviour: :popup,
                                               style: :small_button).render }
        end
      end

      form_name 'status'
    end

    def set_show_fields # rubocop:disable Metrics/AbcSize
      fields[:transaction_id] = { renderer: :label }
      fields[:action_tstamp_tx] = { renderer: :label, caption: 'Time' }
      fields[:table_name] = { renderer: :label }
      fields[:row_data_id] = { renderer: :label, caption: 'ID' }
      fields[:status] = { renderer: :label, with_value: [@form_object[:status], @form_object[:comment]].compact.join(' '), css_class: 'b' }
      fields[:user_name] = { renderer: :label }
      fields[:route_url] = { renderer: :label }
      fields[:request_ip] = { renderer: :label, caption: 'IP Address' }
      fields[:context] = { renderer: :label }
      rules[:headers] = %i[status user_name action_tstamp_tx]
      rules[:details] = @form_object[:logs]
      rules[:header_captions] = { action_tstamp_tx: 'Time' }
      rules[:other_headers] = %i[link table_name row_data_id status user_name action_tstamp_tx]
      rules[:other_details] = @form_object[:other_recs]
      rules[:other_header_captions] = { row_data_id: 'ID', link: 'View', action_tstamp_tx: 'Time' }
      rules[:cols] = %i[status user_name action_tstamp_tx]
    end

    def set_detail_fields
      rules[:cols] = %i[status user_name action_tstamp_tx comment route_url request_ip table_name row_data_id]
      rules[:header_captions] = { action_tstamp_tx: 'Time', row_data_id: 'ID', request_ip: 'IP Address' }
    end

    def select_fields
      {
        table_name: { renderer: :select, options: @dev_repo.table_list, prompt: true, required: true },
        row_data_id: { renderer: :integer, required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :select
      make_detail_form_object && return if @mode == :detail

      @form_object = @repo.find_with_logs(@options[:table_name], @options[:id])
    end

    def make_detail_form_object
      @form_object = @repo.find_status_log_with_details(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(transaction_id: nil,
                                    action_tstamp_tx: nil,
                                    table_name: nil,
                                    row_data_id: nil,
                                    status: nil,
                                    comment: nil,
                                    user_name: nil)
    end
  end
end
