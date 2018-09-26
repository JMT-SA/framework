# frozen_string_literal: true

module DevelopmentApp
  class ContactMethodTypeRepo < BaseRepo
    build_for_select :contact_method_types,
                     label: :contact_method_type,
                     value: :id,
                     order_by: :contact_method_type
    build_inactive_select :contact_method_types,
                          label: :contact_method_type,
                          value: :id,
                          order_by: :contact_method_type

    crud_calls_for :contact_method_types, name: :contact_method_type, wrapper: ContactMethodType
  end
end
