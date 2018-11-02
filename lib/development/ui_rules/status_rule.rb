# frozen_string_literal: true

module UiRules
  class StatusRule < Base
    def generate_rules
      @dev_repo = DevelopmentApp::DevelopmentRepo.new
      @repo = DevelopmentApp::StatusRepo.new
      make_form_object

      common_values_for_fields select_fields

      set_show_fields if @mode == :show
      rules[:rows] = [@form_object.to_h] if @mode == :show

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
      fields[:context] = { renderer: :label }
      rules[:headers] = %i[action_tstamp_tx status comment user_name]
      rules[:details] = @form_object[:logs]
      rules[:header_captions] = { action_tstamp_tx: 'Time' }
      rules[:other_headers] = %i[link table_name row_data_id status comment user_name]
      rules[:other_details] = @form_object[:other_recs]
      rules[:other_header_captions] = { row_data_id: 'ID', link: 'View' }
      rules[:cols] = %i[status user_name route_url action_tstamp_tx table_name row_data_id context]
    end

    def select_fields
      {
        table_name: { renderer: :select, options: @dev_repo.table_list, prompt: true, required: true },
        row_data_id: { renderer: :integer, required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :select

      @form_object = @repo.find_with_logs(@options[:table_name], @options[:id])
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
