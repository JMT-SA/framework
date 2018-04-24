# frozen_string_literal: true

require File.join(File.expand_path('./../../../../', __FILE__), 'test_helper_for_routes')

class TestCountryRoutes < RouteTester
  def around
    MasterfilesApp::DestinationInteractor.any_instance.stubs(:exists?).returns(true)
    super
  end

  def test_edit
    Masterfiles::TargetMarkets::Country::Edit.stub(:call, bland_page) do
      get 'masterfiles/target_markets/destination_countries/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    get 'masterfiles/target_markets/destination_countries/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_show
    Masterfiles::TargetMarkets::Country::Show.stub(:call, bland_page) do
      get 'masterfiles/target_markets/destination_countries/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    get 'masterfiles/target_markets/destination_countries/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_update
    row_vals = Hash.new(1)
    MasterfilesApp::DestinationInteractor.any_instance.stubs(:update_country).returns(ok_response(instance: row_vals))
    patch 'masterfiles/target_markets/destination_countries/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_json_update_grid
  end

  def test_update_fail
    MasterfilesApp::DestinationInteractor.any_instance.stubs(:update_country).returns(bad_response)
    Masterfiles::TargetMarkets::Country::Edit.stub(:call, bland_page) do
      patch 'masterfiles/target_markets/destination_countries/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    MasterfilesApp::DestinationInteractor.any_instance.stubs(:delete_country).returns(ok_response)
    delete 'masterfiles/target_markets/destination_countries/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_json_delete_from_grid
  end
  #
  # def test_delete_fail
  #   MasterfilesApp::DestinationInteractor.any_instance.stubs(:delete_country).returns(bad_response)
  #   delete 'masterfiles/target_markets/destination_countries/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
  #   expect_bad_redirect
  # end

  def test_new
    Masterfiles::TargetMarkets::Country::New.stub(:call, bland_page) do
      get  'masterfiles/target_markets/destination_countries/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    get 'masterfiles/target_markets/destination_countries/new', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_create
    MasterfilesApp::DestinationInteractor.any_instance.stubs(:create_country).returns(ok_response)
    post 'masterfiles/target_markets/destination_countries', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_redirect
  end

  def test_create_remotely
    MasterfilesApp::DestinationInteractor.any_instance.stubs(:create_country).returns(ok_response)
    post_as_fetch 'masterfiles/target_markets/destination_countries', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_json_redirect
  end

  def test_create_fail
    MasterfilesApp::DestinationInteractor.any_instance.stubs(:create_country).returns(bad_response)
    Masterfiles::TargetMarkets::Country::New.stub(:call, bland_page) do
      post 'masterfiles/target_markets/destination_countries', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_bad_redirect(url: '/masterfiles/target_markets/destination_countries/new')
  end

  def test_create_remotely_fail
    MasterfilesApp::DestinationInteractor.any_instance.stubs(:create_country).returns(bad_response)
    Masterfiles::TargetMarkets::Country::New.stub(:call, bland_page) do
      post_as_fetch 'masterfiles/target_markets/destination_countries', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_json_replace_dialog
  end
end
