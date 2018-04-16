# frozen_string_literal: true

require File.join(File.expand_path('./../', __dir__), 'test_helper_for_routes')

class TestCoreRoutes < RouteTester

  def test_root_before_login
    authorise_pass!
    get '/'

    assert last_response.redirect?
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?('Login')
  end

  def test_root_after_login
    authorise_pass!
    get '/', {}, 'rack.session' => { user_id: 1 }

    assert last_response.ok?
    assert last_response.body.include?('Kromco')
  end

  def test_developer_docs
    authorise_pass!
    get '/developer_documentation/start', {}, 'rack.session' => { user_id: 1 }

    assert last_response.ok?
    assert last_response.body.include?('Crossbeams framework')
  end

  def test_developer_yardocs
    authorise_pass!
    get '/yarddocthis/lib=repo_base.rb', {}, 'rack.session' => { user_id: 1 }

    assert last_response.ok?
    assert last_response.body.include?('Yard documentation for methods in lib/repo_base.rb')
  end

  def test_iframe_content
    authorise_pass!
    pf = OpenStruct.new(url: '/path_to_content', program_function_name: 'A PF')
    SecurityApp::MenuRepo.any_instance.stubs(:find_program_function).returns(pf)
    get '/iframe/123', {}, 'rack.session' => { user_id: 1 }

    assert last_response.ok?
    assert last_response.body.include?('<iframe')
  end

  def test_logout
    authorise_pass!
    get '/logout', {}, 'rack.session' => { user_id: 1 }

    assert last_response.redirect?
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?('Login')
  end

  def test_versions
    authorise_pass!
    get '/versions', {}, 'rack.session' => { user_id: 1 }

    assert last_response.ok?
    assert last_response.body.include?('Application')
    assert last_response.body.include?('Crossbeams::Layout')
    assert last_response.body.include?('Crossbeams::Dataminer')
    assert last_response.body.include?('Crossbeams::LabelDesigner')
    assert last_response.body.include?('Crossbeams::RackMiddleware')
    assert last_response.body.include?('Roda::DataGrid')
    assert last_response.body.include?('AG-Grid')
    assert last_response.body.include?('Selectr')
    assert last_response.body.include?('Sortable')
    assert last_response.body.include?('Konva')
    assert last_response.body.include?('Lodash')
    assert last_response.body.include?('Multi')
    assert last_response.body.include?('Sweet Alert2')
  end

  def test_not_found
    authorise_pass!
    get '/not_found', {}, 'rack.session' => { user_id: 1 }

    assert last_response.not_found?
    assert last_response.body.include?('The requested resource was not found')
  end
end
