# frozen_string_literal: true

class DestinationCountryRepo < RepoBase
  def initialize
    main_table :destination_countries
    table_wrapper DestinationCountry
    for_select_options label: :country_name,
                       value: :id,
                       order_by: :country_name
  end
end
