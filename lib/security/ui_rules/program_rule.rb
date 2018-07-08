module UiRules
  class ProgramRule < Base
    def generate_rules
      @repo = SecurityApp::MenuRepo.new
      make_form_object

      common_values_for_fields common_fields

      fields[:functional_area_id] = { renderer: :hidden } if @mode == :new
      if @mode == :edit
        fields[:webapps] = {
          renderer: :multi,
          options: @repo.available_webapps,
          selected: @repo.selected_webapps(@options[:id])
        }
      end

      form_name 'program'.freeze
    end

    def common_fields
      {
        program_name: { required: true },
        program_sequence: { renderer: :number, required: true },
        active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_program(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(functional_area_id: @options[:id],
                                    program_name: nil,
                                    active: true)
    end
  end
end
