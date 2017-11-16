# frozen_string_literal: true

class DestinationCityRepo < RepoBase
  def initialize
    main_table :destination_cities
    table_wrapper DestinationCity
    for_select_options label: :city_name,
                       value: :id,
                       order_by: :city_name
  end
end
