# frozen_string_literal: true

module DevelopmentApp
  class AddressTypeRepo < BaseRepo
    build_for_select :address_types,
                     label: :address_type,
                     value: :id,
                     no_active_check: true,
                     order_by: :address_type

    crud_calls_for :address_types, name: :address_type, wrapper: AddressType
  end
end
