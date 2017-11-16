# frozen_string_literal: true

class BasicPackCodeRepo < RepoBase
  def initialize
    main_table :basic_pack_codes
    table_wrapper BasicPackCode
    for_select_options label: :basic_pack_code,
                       value: :id,
                       order_by: :basic_pack_code
  end
end
