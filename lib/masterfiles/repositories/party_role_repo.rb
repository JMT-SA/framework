# frozen_string_literal: true

class PartyRoleRepo < RepoBase
  def initialize
    main_table :party_roles
    table_wrapper PartyRole
    for_select_options label: :id,
                       value: :id,
                       order_by: :id
  end
end
