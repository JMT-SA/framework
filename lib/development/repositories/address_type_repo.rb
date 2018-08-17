# frozen_string_literal: true

module DevelopmentApp
  class AddressTypeRepo < BaseRepo
    build_for_select :address_types,
                     label: :address_type,
                     value: :id,
                     order_by: :address_type
    build_inactive_select :address_types,
                          label: :address_type,
                          value: :id,
                          order_by: :address_type

    crud_calls_for :address_types, name: :address_type, wrapper: AddressType
  end
end
