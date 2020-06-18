# frozen_string_literal: true

module UiRules
  class StockMovementReportRule < Base
    def generate_rules
      @repo = PackMaterialApp::StockMovementReportRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields case @mode
                               when :new
                                 new_fields
                               else
                                 show_fields
                               end

      form_name 'stock_movement_report'
    end

    def show_fields
      {
        start_date: { renderer: :label },
        end_date: { renderer: :label }
      }
    end

    def new_fields
      {
        start_month: { renderer: :select, options: AppConst::MONTHS_OF_THE_YEAR, sort_items: false, required: true },
        start_year: { renderer: :select, options: AppConst::REPORT_YEARS, required: true },
        end_date: { subtype: :date, required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = OpenStruct.new(start_date: @options[:start_date], end_date: @options[:end_date])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(start_month: nil, start_year: nil, end_date: nil)
    end
  end
end
