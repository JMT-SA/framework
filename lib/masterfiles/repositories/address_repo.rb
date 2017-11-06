# frozen_string_literal: true

class AddressRepo < RepoBase
  def initialize
    main_table :addresses
    table_wrapper Address
    for_select_options label: :address_line_1,
                       value: :id,
                       order_by: :address_line_1
  end
end
