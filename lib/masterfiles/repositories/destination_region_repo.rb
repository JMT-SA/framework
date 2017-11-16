# frozen_string_literal: true

class DestinationRegionRepo < RepoBase
  def initialize
    main_table :destination_regions
    table_wrapper DestinationRegion
    for_select_options label: :destination_region_name,
                       value: :id,
                       order_by: :destination_region_name
  end
end
