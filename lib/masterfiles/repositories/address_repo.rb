# frozen_string_literal: true

class AddressRepo < RepoBase
  def initialize
    main_table :addresses
    table_wrapper Address
    for_select_options label: :address_line_1,
                       value: :id,
                       order_by: :address_line_1
  end

  def find_with_type(id)
    AddressWithType.new(DB[main_table_name].join(:address_types, id: :address_type_id).where(Sequel[main_table_name][:id] => id).first)
  end

  def all_with_type
    DB[main_table_name].join(:address_types, id: :address_type_id).map { |a| AddressWithType.new(a) }
  end
end
