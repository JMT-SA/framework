# frozen_string_literal: true

class ContactMethodTypeRepo < RepoBase
  build_for_select :contact_method_types,
                   label: :contact_method_type,
                   value: :id,
                   order_by: :contact_method_type
end
