# frozen_string_literal: true

class PartyRepo < RepoBase
  def initialize
    main_table :parties
    table_wrapper Party
    for_select_options label: :party_type,
                       value: :id,
                       order_by: :party_type
  end
end
