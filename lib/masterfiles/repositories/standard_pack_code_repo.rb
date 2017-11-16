# frozen_string_literal: true

class StandardPackCodeRepo < RepoBase
  def initialize
    main_table :standard_pack_codes
    table_wrapper StandardPackCode
    for_select_options label: :standard_pack_code,
                       value: :id,
                       order_by: :standard_pack_code
  end
end
