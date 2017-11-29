# frozen_string_literal: true

class AddressTypeRepo < RepoBase
  build_for_select :address_types,
                   label: :address_type,
                   value: :id,
                   order_by: :address_type
end
