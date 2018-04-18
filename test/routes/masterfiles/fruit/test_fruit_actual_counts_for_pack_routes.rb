# frozen_string_literal: true

require File.join(File.expand_path('./../../../../', __FILE__), 'test_helper_for_routes')

class TestFruitActualCountsForPackRoutes < RouteTester
  def around
    MasterfilesApp::FruitActualCountsForPackInteractor.any_instance.stubs(:exists?).returns(true)
    MasterfilesApp::StdFruitSizeCountInteractor.any_instance.stubs(:exists?).returns(true)
    super
  end

  def test_edit
    Masterfiles::Fruit::FruitActualCountsForPack::Edit.stub(:call, bland_page) do
      get 'masterfiles/fruit/fruit_actual_counts_for_packs/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    get 'masterfiles/fruit/fruit_actual_counts_for_packs/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_show
    Masterfiles::Fruit::FruitActualCountsForPack::Show.stub(:call, bland_page) do
      get 'masterfiles/fruit/fruit_actual_counts_for_packs/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    get 'masterfiles/fruit/fruit_actual_counts_for_packs/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_update
    row_vals = Hash.new(1)
    MasterfilesApp::FruitActualCountsForPackInteractor.any_instance.stubs(:update_fruit_actual_counts_for_pack).returns(ok_response(instance: row_vals))
    patch 'masterfiles/fruit/fruit_actual_counts_for_packs/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_json_update_grid
  end

  def test_update_fail
    MasterfilesApp::FruitActualCountsForPackInteractor.any_instance.stubs(:update_fruit_actual_counts_for_pack).returns(bad_response)
    Masterfiles::Fruit::FruitActualCountsForPack::Edit.stub(:call, bland_page) do
      patch 'masterfiles/fruit/fruit_actual_counts_for_packs/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    MasterfilesApp::FruitActualCountsForPackInteractor.any_instance.stubs(:delete_fruit_actual_counts_for_pack).returns(ok_response)
    delete 'masterfiles/fruit/fruit_actual_counts_for_packs/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_json_delete_from_grid
  end
  #
  # def test_delete_fail
  #   MasterfilesApp::FruitActualCountsForPackInteractor.any_instance.stubs(:delete_fruit_actual_counts_for_pack).returns(bad_response)
  #   delete 'masterfiles/fruit/fruit_actual_counts_for_packs/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
  #   expect_bad_redirect
  # end

  def test_new
    Masterfiles::Fruit::FruitActualCountsForPack::New.stub(:call, bland_page) do
      get  'masterfiles/fruit/std_fruit_size_counts/1/fruit_actual_counts_for_packs/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    get 'masterfiles/fruit/std_fruit_size_counts/1/fruit_actual_counts_for_packs/new', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_create
    MasterfilesApp::FruitActualCountsForPackInteractor.any_instance.stubs(:create_fruit_actual_counts_for_pack).returns(ok_response)
    post 'masterfiles/fruit/std_fruit_size_counts/1/fruit_actual_counts_for_packs', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_redirect
  end

  def test_create_remotely
    MasterfilesApp::FruitActualCountsForPackInteractor.any_instance.stubs(:create_fruit_actual_counts_for_pack).returns(ok_response)
    post_as_fetch 'masterfiles/fruit/std_fruit_size_counts/1/fruit_actual_counts_for_packs', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_json_redirect
  end

  def test_create_fail
    MasterfilesApp::FruitActualCountsForPackInteractor.any_instance.stubs(:create_fruit_actual_counts_for_pack).returns(bad_response)
    Masterfiles::Fruit::FruitActualCountsForPack::New.stub(:call, bland_page) do
      post 'masterfiles/fruit/std_fruit_size_counts/1/fruit_actual_counts_for_packs', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_bad_redirect(url: '/masterfiles/fruit/std_fruit_size_counts/1/fruit_actual_counts_for_packs/new')
  end

  def test_create_remotely_fail
    MasterfilesApp::FruitActualCountsForPackInteractor.any_instance.stubs(:create_fruit_actual_counts_for_pack).returns(bad_response)
    Masterfiles::Fruit::FruitActualCountsForPack::New.stub(:call, bland_page) do
      post_as_fetch 'masterfiles/fruit/std_fruit_size_counts/1/fruit_actual_counts_for_packs', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_json_replace_dialog
  end
end
