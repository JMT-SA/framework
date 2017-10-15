module UiRules
  class ProgramFunctions < Base
    def generate_rules
      @this_repo = ProgramFunctionRepo.new
      make_form_object

      common_values_for_fields common_fields

      fields[:program_id] = { renderer: :hidden } if @mode == :new

      form_name 'program_function'.freeze
    end

    def common_fields
      program_id = @mode == :new ? @options[:id] : @form_object.program_id
      {
        program_function_name: {},
        group_name: { datalist: @this_repo.groups_for(program_id) },
        url: {},
        program_function_sequence: { renderer: :number },
        restricted_user_access: { renderer: :checkbox },
        active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(program_id: @options[:id],
                                    program_function_name: nil,
                                    group_name: nil,
                                    url: nil,
                                    program_function_sequence: nil,
                                    restricted_user_access: false,
                                    active: true)
    end
  end
end
