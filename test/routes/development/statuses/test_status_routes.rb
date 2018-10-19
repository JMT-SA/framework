# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestStatusRoutes < RouteTester

  def test_select
    authorise_pass!
    Development::Statuses::Status::Select.stub(:call, bland_page) do
      get 'development/statuses/show', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show
    authorise_pass!
    Development::Statuses::Status::Show.stub(:call, bland_page) do
      get 'development/statuses/show/table_names/123', {}, 'rack.session' => { user_id: 1 }
      # Would be nice to test that the block ran with table_name == 'table_names' and id == 123...
      # mock call
    end
    expect_bland_page
  end
end
