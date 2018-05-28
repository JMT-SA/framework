# frozen_string_literal: true

module UiRules
  class LoggedActionRule < Base
    def generate_rules
      @repo = DevelopmentApp::LoggingRepo.new
      make_form_object
      apply_form_values

      if @mode == :diff
        common_values_for_fields diff_fields
      else
        common_values_for_fields common_fields
      end

      set_show_fields if @mode == :show

      form_name 'logged_action'
    end

    def set_show_fields
      fields[:schema_name] = { renderer: :label }
      fields[:table_name] = { renderer: :label }
      fields[:row_data_id] = { renderer: :label, caption: 'Id' }
    end

    def common_fields
      {
        schema_name: { required: true },
        table_name: { required: true },
        row_data_id: {}
      }
    end

    def diff_fields
      {
        logged_action: {
          # left_caption: 'diff.rb',
          # right_caption: 'show.rb',
          # left_file: '/home/james/ra/crossbeams/framework/lib/development/views/logged_action/diff.rb',
          # right_file: '/home/james/ra/crossbeams/framework/lib/development/views/logged_action/show.rb'
          left_caption: 'Before',
          right_caption: 'After',
          left_record: @options[:left],
          right_record: @options[:right]
        }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_logged_action(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(schema_name: nil,
                                    table_name: nil,
                                    row_data_id: nil)
    end
  end
end
