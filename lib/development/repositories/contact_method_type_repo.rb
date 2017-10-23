# frozen_string_literal: true

class ContactMethodTypeRepo < RepoBase
  def initialize
    main_table :contact_method_types
    table_wrapper ContactMethodType
    for_select_options label: :contact_method_code,
                       value: :id,
                       order_by: :contact_method_code
  end
end
