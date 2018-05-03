ENV['RACK_ENV'] = 'test'
require 'rack/test'
require 'minitest/autorun'
require 'mocha/minitest'
require 'minitest/stub_any_instance'
require 'minitest/hooks/test'

OUTER_APP = Rack::Builder.parse_file('config.ru').first

class RouteTester < Minitest::Test
  include Rack::Test::Methods
  include Minitest::Hooks
  include Crossbeams::Responses

  def around
    DB.transaction(rollback: :always, savepoint: true, auto_savepoint: true) do
      super
    end
  end

  def around_all
    DB.transaction(rollback: :always) do
      super
    end
  end

  def app
    OUTER_APP
  end

  def base_user
    DevelopmentApp::User.new(
      id: 1,
      login_name: 'usr_login',
      user_name: 'User Name',
      password_hash: '$2a$10$wZQEHY77JEp93JgUUyVqgOkwhPb8bYZLswD5NVTWOKwU1ssQTYa.K',
      email: 'current_user@example.com',
      active: true
    )
  end

  def authorise_pass!
    DevelopmentApp::UserRepo.any_instance.stubs(:find).returns(base_user)
    SecurityApp::MenuRepo.any_instance.stubs(:functional_area_id_for_name).returns(1)
    SecurityApp::MenuRepo.any_instance.stubs(:authorise?).returns(true)
  end

  def authorise_fail!
    DevelopmentApp::UserRepo.any_instance.stubs(:find).returns(base_user)
    SecurityApp::MenuRepo.any_instance.stubs(:functional_area_id_for_name).returns(1)
    SecurityApp::MenuRepo.any_instance.stubs(:authorise?).returns(false)
  end

  def ensure_exists!(klass)
    klass.any_instance.stubs(:exists?).returns(true)
  end

  def header_location
    last_response.headers['Location']
  end

  def bland_page(content: 'HTML_PAGE')
    Crossbeams::Layout::Page.build do |page, _|
      page.add_text content
    end
  end

  def ok_response(instance: nil)
    success_response('OK', instance)
  end

  def bad_response
    failed_response('FAILED')
  end

  def expect_json_response
    last_response.headers['Content-Type'] == 'application/json'
  end

  def expect_ok_json_redirect(url: '/')
    assert last_response.ok?
    assert last_response.body.include?('redirect')
    assert last_response.body.include?(url)
    expect_json_response
  end

  def expect_json_replace_dialog(has_error: false, has_notice: false, content: 'HTML_PAGE')
    assert last_response.ok?
    assert last_response.body.include?('replaceDialog')
    assert last_response.body.include?(content)
    assert last_response.body.include?('error') if has_error
    assert last_response.body.include?('notice') if has_notice
    assert last_response.body.include?(bad_response.message)
    expect_json_response
  end

  def expect_json_update_grid(has_error: false, has_notice: false)
    assert last_response.ok?
    assert last_response.body.include?('updateGridInPlace')
    assert last_response.body.include?('error') if has_error
    assert last_response.body.include?('notice') if has_notice
    expect_json_response
  end

  def expect_json_delete_from_grid(has_notice: false)
    assert last_response.ok?
    assert last_response.body.include?('removeGridRowInPlace')
    assert last_response.body.include?('notice') if has_notice
    expect_json_response
  end

  def expect_ok_redirect(url: '/')
    assert last_response.redirect?
    assert_equal url, header_location
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?('OK')
  end

  def expect_bad_redirect(url: '/')
    assert last_response.redirect?
    assert_equal url, header_location
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?('FAIL')
  end

  def expect_bland_page(content: 'HTML_PAGE')
    assert last_response.ok?
    assert_match(/#{content}/, last_response.body)
  end

  def expect_permission_error
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def post_as_fetch(url, params = {}, options = nil)
    post url, params, options.merge('HTTP_X_CUSTOM_REQUEST_TYPE' => 'Y')
  end
end
