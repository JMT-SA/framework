module UiRules
  class ProgramFunctionRule < Base
    def generate_rules
      @repo = SecurityApp::MenuRepo.new
      make_form_object

      common_values_for_fields common_fields

      fields[:program_id] = { renderer: :hidden } if @mode == :new

      form_name 'program_function'.freeze
    end

    def common_fields
      program_id = @mode == :new ? @options[:id] : @form_object.program_id
      {
        program_function_name: { required: true },
        group_name: { datalist: @repo.groups_for(program_id) },
        url: { required: true },
        program_function_sequence: { renderer: :number, required: true },
        restricted_user_access: { renderer: :checkbox },
        active: { renderer: :checkbox },
        show_in_iframe: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_program_function(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(program_id: @options[:id],
                                    program_function_name: nil,
                                    group_name: nil,
                                    url: nil,
                                    program_function_sequence: nil,
                                    restricted_user_access: false,
                                    active: true,
                                    show_in_iframe: false)
    end
  end
end
