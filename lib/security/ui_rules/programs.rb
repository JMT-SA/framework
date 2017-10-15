module UiRules
  class Programs < Base
    def generate_rules
      @this_repo = ProgramRepo.new
      make_form_object

      common_values_for_fields common_fields

      fields[:functional_area_id] = { renderer: :hidden } if @mode == :new

      form_name 'program'.freeze
    end

    def common_fields
      {
        program_name: {},
        active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(functional_area_id: @options[:id],
                                    program_name: nil,
                                    active: true)
    end
  end
end
