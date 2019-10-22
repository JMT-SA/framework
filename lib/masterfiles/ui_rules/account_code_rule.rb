# frozen_string_literal: true

module UiRules
  class AccountCodeRule < Base
    def generate_rules
      @repo = MasterfilesApp::GeneralRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode

      form_name 'account_code'
    end

    def set_show_fields
      fields[:account_code] = { renderer: :label }
      fields[:description] = { renderer: :label }
    end

    def common_fields
      {
        account_code: { renderer: :number, required: true },
        description: { required: true }
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_account_code(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(account_code: nil,
                                    description: nil)
    end
  end
end
