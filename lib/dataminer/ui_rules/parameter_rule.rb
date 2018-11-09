# frozen_string_literal: true

module UiRules
  class ParameterRule < Base
    def generate_rules
      @this_repo = DataminerApp::ReportRepo.new
      @report    = @this_repo.lookup_admin_report(@options[:id])
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      add_behaviours

      preset_disable

      form_name 'report'
    end

    def common_fields
      {
        column: { renderer: :select, options: @report.ordered_columns.map(&:namespaced_name).compact, prompt: true }, # cols...
        table: { renderer: :select, options: @report.tables_or_aliases, prompt: true },
        field: { force_lowercase: true },
        caption: { required: true },
        data_type: { renderer: :select, options: data_types, required: true },
        control_type: { renderer: :select, options: control_types, required: true },
        list_def: { hint: hint_for(:list_def), caption: 'List Definition' },
        default_value: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      # @form_object = @this_repo.find(@options[:id])
      @form_object = OpenStruct.new
    end

    def make_new_form_object
      @form_object = OpenStruct.new(control_type: 'text')
    end

    private

    def data_types
      [
        %w[String string],
        %w[Integer integer],
        %w[Number number],
        %w[Date date],
        %w[Date-Time datetime],
        %w[Boolean boolean]
      ]
    end

    def control_types
      [
        ['Text box', 'text'],
        ['Dropdown list', 'list'],
        ['Date range', 'daterange']
      ]
    end

    # TODO: new behaviour: toggle enabled based on chosen/not chosen value
    def add_behaviours
      behaviours do |behaviour|
        # behaviour.enable :table, when: :applet, changes_to: [''] # ANY VALUE....
        # behaviour.enable :field, when: :applet, changes_to: ['']
        behaviour.enable :list_def, when: :control_type, changes_to: ['list']
      end
    end

    def preset_disable
      # fields[:table][:disabled] = true # unless form_object.applet == 'other'
      # fields[:field][:disabled] = true # unless form_object.applet == 'other'
      fields[:list_def][:disabled] = true unless form_object.control_type == 'list'
    end

    def hint_for(_)
      <<~HTML
        <p>
          The list definition can be an Array or a valid SQL query that returns one or two columns per row.<br>
          If two, the first will be displayed and the second will be the returned value.
        </p>
        <p>
          The list can also be an array of fixed items. An array must start with <strong>[</strong> and end with <strong>]</strong>.<br>
          Items must be separated by commas.<br>
          A 2-dimensional array must be entered as sets of 2 items within <strong>[</strong> and <strong>]</strong> pairs.
        </p>
        <p><strong>Examples</strong></p>
          <ul>
            <li>SQL: SELECT code from table ORDER BY code</li>
            <li>SQL: SELECT code, id FROM table.</li>
            <li>ARRAY: <code>[one, two, three]</code></li>
            <li>ARRAY: <code>[one, 1], [two, 2], [three, 3]</code></li></ul>
      HTML
    end
  end
end
