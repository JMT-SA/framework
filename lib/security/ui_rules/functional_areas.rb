module UiRules
  class FunctionalAreas < Base
    def generate_rules
      @this_repo = FunctionalAreaRepo.new
      make_form_object

      common_values_for_fields common_fields

      form_name 'functional_area'.freeze
    end

    def common_fields
      {
        functional_area_name: {},
        active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find(:functional_areas, FunctionalArea, @options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(functional_area_name: nil,
                                    active: true)
    end
  end
end
