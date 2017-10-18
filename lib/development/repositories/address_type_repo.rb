# frozen_string_literal: true

class AddressTypeRepo < RepoBase
  def initialize
    main_table :address_types
    table_wrapper AddressType
    for_select_options label: :address_type,
                       value: :id,
                       order_by: :address_type
  end
end