# frozen_string_literal: true

module UiRules
  class ScriptScaffoldRule < Base
    def generate_rules
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      form_name 'scaffold'
    end

    def common_fields
      {
        script_class: { required: true, caption: 'Script class name (like FixThisThing)' },
        description: { renderer: :textarea, required: true, caption: 'What this script does' },
        reason: { renderer: :textarea, required: true, caption: 'Reason for writing this script' }
      }
    end

    def make_form_object
      @form_object = OpenStruct.new(script_class: nil,
                                    description: nil,
                                    reason: nil)
    end
  end
end
