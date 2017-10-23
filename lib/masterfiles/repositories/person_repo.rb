# frozen_string_literal: true

class PersonRepo < RepoBase
  def initialize
    main_table :people
    table_wrapper Person
    for_select_options label: :surname,
                       value: :id,
                       order_by: :surname
  end
end
