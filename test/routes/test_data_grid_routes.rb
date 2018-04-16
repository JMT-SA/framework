# frozen_string_literal: true

require File.join(File.expand_path('./../', __dir__), 'test_helper_for_routes')

class TestDataGridRoutes < RouteTester
  # list
  #  :id
  #    with_params
  #    multi
  #    grid
  #    grid_multi
  #    nested_grid
  # print_grid
  # search
  #   :id
  #     run
  #     grid
  #     xls
end
