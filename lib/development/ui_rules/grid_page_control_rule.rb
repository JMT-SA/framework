# frozen_string_literal: true

module UiRules
  class GridPageControlRule < Base
    def generate_rules
      @repo = DevelopmentApp::RoleRepo.new
      make_form_object
      # apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'page_control'
    end

    def set_show_fields
      fields[:text] = { renderer: :label }
      fields[:control_type] = { renderer: :label }
      fields[:url] = { renderer: :label }
      fields[:style] = { renderer: :label }
      fields[:behaviour] = { renderer: :label }
    end

    def common_fields
      {
        list_file: { renderer: :hidden },
        index: { renderer: :hidden },
        text: {},
        control_type: { renderer: :select, options: %w[link] },
        url: {},
        style: { renderer: :select, options: %w[link button] },
        behaviour: { renderer: :select, options: %w[direct popup] }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @options[:form_values]
    end

    def make_new_form_object
      # TODO: branch out...
      @form_object = OpenStruct.new(name: nil,
                                    active: true)
    end
  end
end
