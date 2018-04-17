# frozen_string_literal: true

require File.join(File.expand_path('./../../../../', __FILE__), 'test_helper_for_routes')

class TestContactMethodRoutes < RouteTester
  def around
    MasterfilesApp::ContactMethodInteractor.any_instance.stubs(:exists?).returns(true)
    super
  end

  def test_edit
    Masterfiles::Parties::ContactMethod::Edit.stub(:call, bland_page) do
      get 'masterfiles/parties/contact_methods/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    get 'masterfiles/parties/contact_methods/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_show
    Masterfiles::Parties::ContactMethod::Show.stub(:call, bland_page) do
      get 'masterfiles/parties/contact_methods/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    get 'masterfiles/parties/contact_methods/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_update
    row_vals = Hash.new(1)
    MasterfilesApp::ContactMethodInteractor.any_instance.stubs(:update_contact_method).returns(ok_response(instance: row_vals))
    patch 'masterfiles/parties/contact_methods/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_json_update_grid
  end

  def test_update_fail
    MasterfilesApp::ContactMethodInteractor.any_instance.stubs(:update_contact_method).returns(bad_response)
    Masterfiles::Parties::ContactMethod::Edit.stub(:call, bland_page) do
      patch 'masterfiles/parties/contact_methods/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    MasterfilesApp::ContactMethodInteractor.any_instance.stubs(:delete_contact_method).returns(ok_response)
    delete 'masterfiles/parties/contact_methods/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_json_delete_from_grid
  end
  #
  # def test_delete_fail
  #   MasterfilesApp::ContactMethodInteractor.any_instance.stubs(:delete_contact_method).returns(bad_response)
  #   delete 'masterfiles/parties/contact_methods/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
  #   expect_bad_redirect
  # end

  def test_new
    Masterfiles::Parties::ContactMethod::New.stub(:call, bland_page) do
      get  'masterfiles/parties/contact_methods/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    get 'masterfiles/parties/contact_methods/new', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_create
    MasterfilesApp::ContactMethodInteractor.any_instance.stubs(:create_contact_method).returns(ok_response)
    post 'masterfiles/parties/contact_methods', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_redirect
  end

  def test_create_remotely
    MasterfilesApp::ContactMethodInteractor.any_instance.stubs(:create_contact_method).returns(ok_response)
    post_as_fetch 'masterfiles/parties/contact_methods', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_json_redirect
  end

  def test_create_fail
    MasterfilesApp::ContactMethodInteractor.any_instance.stubs(:create_contact_method).returns(bad_response)
    Masterfiles::Parties::ContactMethod::New.stub(:call, bland_page) do
      post 'masterfiles/parties/contact_methods', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_bad_redirect(url: '/masterfiles/parties/contact_methods/new')
  end

  def test_create_remotely_fail
    MasterfilesApp::ContactMethodInteractor.any_instance.stubs(:create_contact_method).returns(bad_response)
    Masterfiles::Parties::ContactMethod::New.stub(:call, bland_page) do
      post_as_fetch 'masterfiles/parties/contact_methods', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_json_replace_dialog
  end
end
