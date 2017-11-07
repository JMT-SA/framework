# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

# TODO: Get rubocop in from the start....

require 'roda'
require 'rodauth'
require 'awesome_print'
# require 'sequel'
require 'crossbeams/layout'
require 'crossbeams/dataminer'
require 'crossbeams/dataminer_interface'
require 'crossbeams/label_designer'
require 'crossbeams/rack_middleware'
require 'yaml'
require 'base64'
require 'dry-struct'
require 'dry-validation'
require 'asciidoctor'
# require 'pry' # TODO: Put this in based on dev env.

module Types
  include Dry::Types.module
end

require './lib/repo_base'
require './lib/base_interactor'
require './lib/base_service'
require './lib/ui_rules'
require './lib/library_versions'
Dir['./helpers/**/*.rb'].each { |f| require f }
Dir['./lib/applets/*.rb'].each { |f| require f }

ENV['ROOT'] = File.dirname(__FILE__)

class Framework < Roda
  include CommonHelpers
  include MenuHelpers

  use Rack::Session::Cookie, secret: 'some_other_nice_long_random_string_DSKJH4378EYR7EGKUFH', key: '_myapp_session'
  use Rack::MethodOverride # Use with all_verbs plugin to allow 'r.delete' etc.
  use Crossbeams::RackMiddleware::Banner, template: 'views/_page_banner.erb' # , session: request.session
  use Crossbeams::DataminerInterface::App,
      url_prefix: 'dataminer/',
      dm_reports_location: File.join(File.dirname(__FILE__), 'reports'),
      dm_grid_queries_location: File.join(File.dirname(__FILE__), 'grid_definitions', 'dataminer_queries'),
      dm_js_location: 'js',
      dm_css_location: 'css',
      db_connection: DB

  plugin :data_grid, path: File.dirname(__FILE__),
                     list_url: '/list/%s/grid',
                     list_nested_url: '/list/%s/nested_grid',
                     list_multi_url: '/list/%s/grid_multi',
                     search_url: '/search/%s/grid',
                     filter_url: '/search/%s',
                     run_search_url: '/search/%s/run',
                     run_to_excel_url: '/search/%s/xls'
  plugin :all_verbs
  plugin :render
  plugin :partials
  plugin :assets, css: 'style.scss' # , js: 'behave.js'
  plugin :public # serve assets from public folder.
  plugin :view_options
  plugin :multi_route
  plugin :content_for, append: true
  # plugin :indifferent_params # - allows access to params by string or symbol.
  plugin :symbolized_params    # - automatically converts all keys of params to symbols.
  plugin :flash
  plugin :csrf, raise: true  # , :skip => ['POST:/report_error'] # FIXME: Remove the +raise+ param when going live!
  plugin :rodauth do
    db DB # .connection
    enable :login, :logout # , :change_password
    logout_route 'a_dummy_route' # Override 'logout' route so that we have control over it.
    # logout_notice_flash 'Logged out'
    session_key :user_id
    login_param 'login_name' # 'user_name'
    login_label 'Login name'
    login_column :login_name # :user_name
    accounts_table :users
    account_password_hash_column :password_hash # :hashed_password (This is old base64 version)
    # require_bcrypt? false
    # password_match? do |password| # Use legacy password hashing. Maybe change this to modern bcrypt using extra new pwd field?
    #   account[:hashed_password] == Base64.encode64(password)
    # end
    # title_instance_variable :@title
    # if DEMO_MODE
    #   before_change_password{r.halt(404)}
    # end
  end
  # plugin :error_handler do |e|
  #   # TODO: how to handle AJAX/JSON etc...
  #   view(inline: "An error occurred - #{e.message}") # TODO: refine this to handle certain classes of errors in certain ways.
  #   # (could do something like - inline: render errorview(e) ...)
  # end
  Dir['./routes/*.rb'].each { |f| require f }

  route do |r|
    r.assets unless ENV['RACK_ENV'] == 'production'
    r.public

    r.rodauth
    rodauth.require_authentication
    r.redirect('/login') if current_user.nil? # Session might have the incorrect user_id

    r.root do
      s = <<-HTML
      <h2>Kromco packhouse</h2>
      <p>There are currently 99 bins and 99 pallets on site.</p>
      <p>Since 1 December 2016: <ul>
      <li>99 deliveries have been received</li>
      <li>99 cartons have been packed</li>
      </p>
      HTML
      view(inline: s)
    end

    r.on 'developer_documentation', String do |file|
      content = File.read(File.join(File.dirname(__FILE__), 'developer_documentation', "#{file}.adoc"))
      view(inline: <<~HTML)
        <% content_for :late_head do %>
          <link rel="stylesheet" href="/css/asciidoc.css">
        <% end %>
        <div id="asciidoc-content">
          #{Asciidoctor.convert(content, safe: :safe)}
        </div>
      HTML
    end

    r.multi_route

    r.is 'test' do
      view('test_view')
    end

    r.is 'logout' do
      rodauth.logout
      flash[:notice] = 'Logged out'
      r.redirect('/login')
    end

    r.is 'versions' do
      view(inline: LibraryVersions.new(:layout,
                                       :dataminer,
                                       :label_designer,
                                       :rackmid,
                                       :datagrid,
                                       :ag_grid,
                                       :selectr).to_html)
    end

    r.is 'not_found' do
      response.status = 404
      view(inline: '<div class="crossbeams-error-note"><strong>Error</strong><br>The requested resource was not found.</div>')
    end

    # Generic grid lists.
    r.on 'list' do
      r.on :id do |id|
        r.is do
          session[:last_grid_url] = "/list/#{id}"
          show_page { render_data_grid_page(id) }
        end

        r.on 'with_params' do
          p "PARAMS #{request.query_string} - #{params.inspect}"
          session[:last_grid_url] = "/list/#{id}/with_params?#{request.query_string}"
          show_page { render_data_grid_page(id, query_string: request.query_string) }
        end

        r.on 'multi' do
          show_page { render_data_grid_page_multiselect(id, params) }
        end

        r.on 'grid' do
          response['Content-Type'] = 'application/json'
          if params
            render_data_grid_rows(id, ->(program, permission) { auth_blocked?(program, permission) }, params)
          else
            render_data_grid_rows(id, ->(program, permission) { auth_blocked?(program, permission) })
          end
        end

        r.on 'grid_multi', String do |key|
          response['Content-Type'] = 'application/json'
          render_data_grid_multiselect_rows(id, ->(program, permission) { auth_blocked?(program, permission) }, key, params)
        end

        r.on 'nested_grid' do
          response['Content-Type'] = 'application/json'
          render_data_grid_nested_rows(id)
        end
      end
    end

    # - :url: "/list/users/multi?key=program_users&id=$:id$/"

    # In-page grids (no last grid_url)
    # 1) list with multi-select - might need last_grid
    # 2) list_section - never use last_grid
    r.on 'list_section' do
      # list_section/users/?user_id=123&multi_select=fredo
      # open users yml & look for fredo multiselect to get rules
      #
      # list_section/users/?user_id=123
      # open users yml & apply user_id param
      #
    end

    # Generic code for grid searches.
    r.on 'search' do
      r.on :id do |id|
        r.is do
          render_search_filter(id, params)
        end

        r.on 'run' do
          session[:last_grid_url] = "/search/#{id}?rerun=y"
          show_page { render_search_grid_page(id, params) }
        end

        r.on 'grid' do
          response['Content-Type'] = 'application/json'
          render_search_grid_rows(id, params, ->(program, permission) { auth_blocked?(program, permission) })
        end

        r.on 'xls' do
          begin
            caption, xls = render_excel_rows(id, params)
            response.headers['content_type'] = 'application/vnd.ms-excel'
            response.headers['Content-Disposition'] = "attachment; filename=\"#{caption.strip.gsub(%r{[/:*?"\\<>\|\r\n]}i, '-') + '.xls'}\""
            response.write(xls) # NOTE: could this use streaming to start downloading quicker?
          rescue Sequel::DatabaseError => e
            view(inline: <<-HTML)
            <p style='color:red;'>There is a problem with the SQL definition of this report:</p>
            <p>Report: <em>#{caption}</em></p>The error message is:
            <pre>#{e.message}</pre>
            <button class="pure-button" onclick="crossbeamsUtils.toggleVisibility('sql_code', this);return false">
              <i class="fa fa-info"></i> Toggle SQL
            </button>
            <pre id="sql_code" style="display:none;"><%= sql_to_highlight(@rpt.runnable_sql) %></pre>
            HTML
          end
        end
      end
    end
  end
end
