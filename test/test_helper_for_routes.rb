ENV['RACK_ENV'] = 'test'
require 'rack/test'
require 'minitest/autorun'
require 'mocha/minitest'
require 'minitest/stub_any_instance'
require 'minitest/hooks/test'

require 'dotenv'
Dotenv.load('.env.local', '.env')

OUTER_APP = Rack::Builder.parse_file('config.ru').first

class RouteTester < Minitest::Test
  include Rack::Test::Methods
  include Minitest::Hooks
  include Crossbeams::Responses

  DEFAULT_LAST_GRID_URL = '/list/users'

  def around
    Faker::UniqueGenerator.clear
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

  def authorise_pass!(permission_check: nil)
    DevelopmentApp::UserRepo.any_instance.stubs(:find).returns(base_user)
    SecurityApp::MenuRepo.any_instance.stubs(:functional_area_id_for_name).returns(1)
    SecurityApp::MenuRepo.any_instance.stubs(:authorise?).returns(true)
    permission_check.any_instance.stubs(:call).returns(ok_response) if permission_check
  end

  def authorise_fail!
    DevelopmentApp::UserRepo.any_instance.stubs(:find).returns(base_user)
    SecurityApp::MenuRepo.any_instance.stubs(:functional_area_id_for_name).returns(1)
    SecurityApp::MenuRepo.any_instance.stubs(:authorise?).returns(false)
  end

  def ensure_exists!(klass)
    klass.any_instance.stubs(:exists?).returns(true)
  end

  def bland_page(content: 'HTML_PAGE')
    Crossbeams::Layout::Page.build do |page, _|
      page.add_text content
    end
  end

  def ok_response(message: nil, instance: nil)
    success_response((message || 'OK'), instance.nil? ? nil : OpenStruct.new(instance))
  end

  def bad_response(message: nil, instance: nil)
    failed_response((message || 'FAILED'), instance.nil? ? nil : OpenStruct.new(instance))
  end

  def has_json_response
    last_response.content_type == 'application/json'
  end

  def expect_json_response
    assert has_json_response, "Expected JSON headers, got '#{last_response.content_type}' - from: #{caller.first}"
  end

  def expect_ok_json_redirect(url: '/')
    assert last_response.ok?, "Expected last response to be OK (status is #{last_response.status}) - from: #{caller.first}"
    assert last_response.body.include?('redirect'), "Expected redirect - from: #{caller.first}"
    assert last_response.body.include?(url), "Expected URL '#{url}' as redirect - from: #{caller.first}"
    assert has_json_response, "Expected JSON headers, got '#{last_response.content_type}' - from: #{caller.first}"
  end

  def expect_json_replace_dialog(has_error: false, has_notice: false, content: 'HTML_PAGE')
    assert last_response.ok?, "Expected last response to be OK (status is #{last_response.status}) - from: #{caller.first}"
    assert last_response.body.include?('replaceDialog'), "Expected 'replaceDialog' in last response - from: #{caller.first}"
    assert last_response.body.include?(content), "Expected to include content '#{content}' - from: #{caller.first}"
    assert last_response.body.include?('error'), "Expected last response to include error flash - from: #{caller.first}" if has_error
    assert last_response.body.include?('notice'), "Expected last response to include notice flash - from: #{caller.first}" if has_notice
    assert last_response.body.include?(bad_response.message)
    assert has_json_response, "Expected JSON headers, got '#{last_response.content_type}' - from: #{caller.first}"
  end

  def expect_json_update_grid(has_error: false, has_notice: false)
    assert last_response.ok?, "Expected last response to be OK (status is #{last_response.status}) - from: #{caller.first}"
    assert last_response.body.include?('updateGridInPlace'), "Expected 'updateGridRowInPlace' in last response - from: #{caller.first}"
    assert last_response.body.include?('error'), "Expected last response to include error flash - from: #{caller.first}" if has_error
    assert last_response.body.include?('notice'), "Expected last response to include notice flash - from: #{caller.first}" if has_notice
    assert has_json_response, "Expected JSON headers, got '#{last_response.content_type}' - from: #{caller.first}"
  end

  def expect_json_add_to_grid(has_notice: false)
    assert last_response.ok?, "Expected last response to be OK (status is #{last_response.status}) - from: #{caller.first}"
    assert last_response.body.include?('addRowToGrid'), "Expected 'addRowToGrid' in last response - from: #{caller.first}"
    assert last_response.body.include?('notice'), "Expected last response to include notice flash - from: #{caller.first}" if has_notice
    assert has_json_response, "Expected JSON headers, got '#{last_response.content_type}' - from: #{caller.first}"
  end

  def expect_json_delete_from_grid(has_notice: false)
    assert last_response.ok?, "Expected last response to be OK (status is #{last_response.status}) - from: #{caller.first}"
    assert last_response.body.include?('removeGridRowInPlace'), "Expected 'removeGridRowInPlace' in last response - from: #{caller.first}"
    assert last_response.body.include?('notice'), "Expected last response to include notice flash - from: #{caller.first}" if has_notice
    assert has_json_response, "Expected JSON headers, got '#{last_response.content_type}' - from: #{caller.first}"
  end

  def expect_json_error(message: 'FAILED')
    assert last_response.ok?, "Expected last response to be OK (status is #{last_response.status}) - from: #{caller.first}"
    assert last_response.body.include?('exception'), "Expected 'exception' in last response - from: #{caller.first}"
    assert last_response.body.include?(message), "Expected last response to include error message '#{message}' - from: #{caller.first}"
    assert has_json_response, "Expected JSON headers, got '#{last_response.content_type}' - from: #{caller.first}"
  end

  def expect_ok_redirect(url: DEFAULT_LAST_GRID_URL, has_dummy_content: true, follow_redirect: true)
    assert last_response.redirect?, "Expected last response to be redirect (status is #{last_response.status}, location is #{last_response.location}) - from: #{caller.first}"
    assert_equal url, last_response.location, "Expected redirect to '#{url}', was '#{last_response.location}' - from: #{caller.first}"
    return unless follow_redirect

    follow_redirect!
    assert last_response.ok?, "Expected last response to be OK (status is #{last_response.status}) - from: #{caller.first}"
    assert last_response.body.include?('OK'), "Expected 'OK' in last response - from: #{caller.first}" if has_dummy_content
  end

  def expect_bad_redirect(url: DEFAULT_LAST_GRID_URL)
    assert last_response.redirect?, "Expected last response to be redirect (status is #{last_response.status}, location is #{last_response.location}) - from: #{caller.first}"
    assert_equal url, last_response.location, "Expected redirect to '#{url}', was '#{last_response.location}' - from: #{caller.first}"
    follow_redirect!
    assert last_response.ok?, "Expected last response to be OK (status is #{last_response.status}) - from: #{caller.first}"
    assert last_response.body.include?('FAIL'), "Expected 'FAIL' in last response - from: #{caller.first}"
  end

  def expect_bad_page(content: 'FAIL')
    assert last_response.ok?, "Expected last response to be OK (status is #{last_response.status}) - from: #{caller.first}"
    assert_match(/#{content}/, last_response.body, "Expected '#{content}' in body - from: #{caller.first}")
  end

  def expect_bland_page(content: 'HTML_PAGE')
    assert last_response.ok?, "Expected last response to be OK (status is #{last_response.status}) - from: #{caller.first}"
    assert_match(/#{content}/, last_response.body, "Expected '#{content}' in body - from: #{caller.first}")
  end

  def expect_permission_error
    refute last_response.ok?, "Expected last response to be fail (status is #{last_response.status}) - from: #{caller.first}"
    assert_match(/permission/i, last_response.body, "Expected 'permission' in body - from: #{caller.first}")
  end

  def post_as_fetch(url, params = {}, options = nil)
    post url, params, options.merge('HTTP_X_CUSTOM_REQUEST_TYPE' => 'Y')
  end

  def patch_as_fetch(url, params = {}, options = nil)
    patch url, params, options.merge('HTTP_X_CUSTOM_REQUEST_TYPE' => 'Y')
  end

  def get_as_fetch(url, params = {}, options = nil)
    get url, params, options.merge('HTTP_X_CUSTOM_REQUEST_TYPE' => 'Y')
  end

  def delete_as_fetch(url, params = {}, options = nil)
    delete url, params, options.merge('HTTP_X_CUSTOM_REQUEST_TYPE' => 'Y')
  end

  def expect_flash_notice(message = nil)
    assert last_request.session['_flash'], "Expected flash to be in session (#{last_request.session}) - from: #{caller.first}"
    if message
      assert_equal message, last_request.session['_flash'][:notice], "Expected '#{message}' in session flash notice - from: #{caller.first}"
    else
      assert_equal 'OK', last_request.session['_flash'][:notice], "Expected 'OK' in session flash notice - from: #{caller.first}"
    end
  end

  def expect_flash_error(message = nil)
    assert last_request.session['_flash'], "Expected flash to be in session (#{last_request.session}) - from: #{caller.first}"
    if message
      assert_equal message, last_request.session['_flash'][:error], "Expected '#{message}' in session flash error - from: #{caller.first}"
    else
      assert_equal 'FAILED', last_request.session['_flash'][:error], "Expected 'FAILED' in session flash error - from: #{caller.first}"
    end
  end
end
