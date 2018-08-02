# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestBasicPackCodeRoutes < RouteTester

  INTERACTOR = MasterfilesApp::BasicPackCodeInteractor

  def test_edit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Masterfiles::Fruit::BasicPackCode::Edit.stub(:call, bland_page) do
      get 'masterfiles/fruit/basic_pack_codes/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'masterfiles/fruit/basic_pack_codes/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_show
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Masterfiles::Fruit::BasicPackCode::Show.stub(:call, bland_page) do
      get 'masterfiles/fruit/basic_pack_codes/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'masterfiles/fruit/basic_pack_codes/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    MasterfilesApp::BasicPackCodeInteractor.any_instance.stubs(:update_basic_pack_code).returns(ok_response(instance: row_vals))
    patch 'masterfiles/fruit/basic_pack_codes/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_update_grid
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    MasterfilesApp::BasicPackCodeInteractor.any_instance.stubs(:update_basic_pack_code).returns(bad_response)
    Masterfiles::Fruit::BasicPackCode::Edit.stub(:call, bland_page) do
      patch 'masterfiles/fruit/basic_pack_codes/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    authorise_pass!
    ensure_exists!(INTERACTOR)
    MasterfilesApp::BasicPackCodeInteractor.any_instance.stubs(:delete_basic_pack_code).returns(ok_response)
    delete 'masterfiles/fruit/basic_pack_codes/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_delete_from_grid
  end
  #
  # def test_delete_fail
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   MasterfilesApp::BasicPackCodeInteractor.any_instance.stubs(:delete_basic_pack_code).returns(bad_response)
  #   delete 'masterfiles/fruit/basic_pack_codes/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   expect_bad_redirect
  # end

  def test_new
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Masterfiles::Fruit::BasicPackCode::New.stub(:call, bland_page) do
      get  'masterfiles/fruit/basic_pack_codes/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'masterfiles/fruit/basic_pack_codes/new', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_create
    authorise_pass!
    ensure_exists!(INTERACTOR)
    MasterfilesApp::BasicPackCodeInteractor.any_instance.stubs(:create_basic_pack_code).returns(ok_response)
    post 'masterfiles/fruit/basic_pack_codes', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_redirect
  end

  def test_create_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    MasterfilesApp::BasicPackCodeInteractor.any_instance.stubs(:create_basic_pack_code).returns(ok_response)
    post_as_fetch 'masterfiles/fruit/basic_pack_codes', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_json_redirect
  end

  def test_create_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    MasterfilesApp::BasicPackCodeInteractor.any_instance.stubs(:create_basic_pack_code).returns(bad_response)
    Masterfiles::Fruit::BasicPackCode::New.stub(:call, bland_page) do
      post 'masterfiles/fruit/basic_pack_codes', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_redirect(url: '/masterfiles/fruit/basic_pack_codes/new')
  end

  def test_create_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    MasterfilesApp::BasicPackCodeInteractor.any_instance.stubs(:create_basic_pack_code).returns(bad_response)
    Masterfiles::Fruit::BasicPackCode::New.stub(:call, bland_page) do
      post_as_fetch 'masterfiles/fruit/basic_pack_codes', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end
end
