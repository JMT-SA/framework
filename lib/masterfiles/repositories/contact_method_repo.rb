# frozen_string_literal: true

class ContactMethodRepo < RepoBase
  def initialize
    main_table :contact_methods
    table_wrapper ContactMethod
    for_select_options label: :contact_method_code,
                       value: :id,
                       order_by: :contact_method_code
  end

  def find_with_type(id)
    ContactMethodWithType.new(DB[main_table_name].join(:contact_method_types, id: :contact_method_type_id).where(Sequel[main_table_name][:id] => id).first)
  end

  def all_with_type
    DB[main_table_name].join(:contact_method_types, id: :contact_method_type_id).map { |a| ContactMethodWithType.new(a) }
  end
end
