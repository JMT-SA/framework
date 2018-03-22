require File.join(File.expand_path('./../../', __FILE__), 'test_helper_for_routes')

class TestSecurityRoutes < RouteTester
  def around
    FunctionalAreaInteractor.any_instance.stubs(:exists?).returns(true)
    super
  end

  def test_edit
    Security::FunctionalAreas::FunctionalArea::Edit.stub(:call, bland_page) do
      get 'security/functional_areas/functional_areas/2/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    get 'security/functional_areas/functional_areas/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end
  #
  # def test_show
  #   Security::FunctionalAreas::FunctionalArea::Show.stub(:call, bland_page) do
  #     get 'security/functional_areas/functional_areas/1', {}, 'rack.session' => { user_id: 1 }
  #   end
  #   assert last_response.ok?
  # end

  def test_show_fail
    authorise_fail!
    get 'security/functional_areas/functional_areas/1', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_new
    Security::FunctionalAreas::FunctionalArea::New.stub(:call, bland_page) do
      get 'security/functional_areas/functional_areas/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    get 'security/functional_areas/functional_areas/new', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_delete
    FunctionalAreaInteractor.any_instance.stubs(:delete_functional_area).returns(ok_response)
    delete 'security/functional_areas/functional_areas/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_redirect
  end

  def test_delete_fail
    FunctionalAreaInteractor.any_instance.stubs(:delete_functional_area).returns(bad_response)
    delete 'security/functional_areas/functional_areas/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_bad_redirect
  end

  def test_update
    FunctionalAreaInteractor.any_instance.stubs(:update_functional_area).returns(ok_response)
    patch 'security/functional_areas/functional_areas/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_json_redirect
  end

  def test_update_fail
    FunctionalAreaInteractor.any_instance.stubs(:update_functional_area).returns(bad_response)
    Security::FunctionalAreas::FunctionalArea::Edit.stub(:call, bland_page) do
      patch 'security/functional_areas/functional_areas/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_create
    FunctionalAreaInteractor.any_instance.stubs(:create_functional_area).returns(ok_response)
    post 'security/functional_areas/functional_areas', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_redirect
  end

  def test_create_remotely
    FunctionalAreaInteractor.any_instance.stubs(:create_functional_area).returns(ok_response)
    post_as_fetch 'security/functional_areas/functional_areas', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_json_redirect
  end

  def test_create_fail
    FunctionalAreaInteractor.any_instance.stubs(:create_functional_area).returns(bad_response)
    Security::FunctionalAreas::FunctionalArea::New.stub(:call, bland_page) do
      post 'security/functional_areas/functional_areas', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_bland_page
  end

  def test_create_remotely_fail
    FunctionalAreaInteractor.any_instance.stubs(:create_functional_area).returns(bad_response)
    Security::FunctionalAreas::FunctionalArea::New.stub(:call, bland_page) do
      post_as_fetch 'security/functional_areas/functional_areas', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_json_replace_dialog
  end
end
