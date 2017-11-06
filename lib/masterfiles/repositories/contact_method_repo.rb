# frozen_string_literal: true

class ContactMethodRepo < RepoBase
  def initialize
    main_table :contact_methods
    table_wrapper ContactMethod
    for_select_options label: :contact_method_code,
                       value: :id,
                       order_by: :contact_method_code
  end
end
