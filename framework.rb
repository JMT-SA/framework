# frozen_string_literal: true

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
# require 'pry' # TODO: Put this in based on dev env.

module Types
  include Dry::Types.module
end

require './lib/repo_base'
Dir['./helpers/**/*.rb'].each { |f| require f }
Dir['./lib/applets/*.rb'].each { |f| require f }

class Framework < Roda
  include CommonHelpers

  use Rack::Session::Cookie, secret: "some_other_nice_long_random_string_DSKJH4378EYR7EGKUFH", key: "_myapp_session"
  use Rack::MethodOverride # USe with all_verbs plugin to allow "r.delete" etc.
  use Crossbeams::RackMiddleware::Banner, template: 'views/_page_banner.erb'#, session: request.session
  use Crossbeams::DataminerInterface::App, url_prefix: 'dataminer/',
    dm_reports_location: File.join(File.dirname(__FILE__), 'reports'),
    dm_js_location: 'js', dm_css_location: 'css', db_connection: DB

  plugin :data_grid, path: File.dirname(__FILE__),
                     list_url: '/list/%s/grid',
                     list_nested_url: '/list/%s/nested_grid',
                     search_url: '/search/%s/grid',
                     filter_url: '/search/%s',
                     run_search_url: '/search/%s/run',
                     run_to_excel_url: '/search/%s/xls'
  plugin :all_verbs
  plugin :render
  plugin :partials
  plugin :assets, css: 'style.scss'#, js: 'behave.js'
  plugin :public # serve assets from public folder.
  plugin :view_options
  plugin :multi_route
  plugin :content_for, :append=>true
  # plugin :indifferent_params # - allows access to params by string or symbol.
  plugin :symbolized_params    # - automatically converts all keys of params to symbols.
  plugin :flash
  plugin :csrf, raise: true  # , :skip => ['POST:/report_error'] # FIXME: Remove the +raise+ param when going live!
  plugin :rodauth do
      db DB # .connection
      enable :login, :logout#, :change_password
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
      s = <<-EOS
      <h2>Kromco packhouse</h2>
      <p>There are currently 99 bins and 99 pallets on site.</p>
      <p>Since 1 December 2016: <ul>
      <li>99 deliveries have been received</li>
      <li>99 cartons have been packed</li>
      </p>
      EOS
      view(inline: s)
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
      s = String.new('<h2>Gem Versions</h2><ul><li>')
      s << [Crossbeams::Layout,
            Crossbeams::Dataminer,
            Crossbeams::LabelDesigner,
            Crossbeams::RackMiddleware,
            Roda::DataGrid].map { |k| "#{k}: #{k.const_get('VERSION')}" }.join('</li><li>')
      s << '</li></ul>'
      view(inline: s)
    end

    # Generic grid lists.
    r.on 'list' do
      r.on :id do |id|
        r.is do
          session[:last_grid_url] = "/list/#{id}"
          show_page { render_data_grid_page(id) }
        end

        r.on 'grid' do
          response['Content-Type'] = 'application/json'
          render_data_grid_rows(id, lambda { |program, permission| auth_blocked?(program, permission) })
        end

        r.on 'nested_grid' do
          response['Content-Type'] = 'application/json'
          render_data_grid_nested_rows(id)
        end
      end
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
          render_search_grid_rows(id, params, lambda { |program, permission| auth_blocked?(program, permission) })
        end

        r.on 'xls' do
          begin
            caption, xls = render_excel_rows(id, params)
            response.headers['content_type'] = "application/vnd.ms-excel"
            response.headers['Content-Disposition'] = "attachment; filename=\"#{caption.strip.gsub(/[\/:*?"\\<>\|\r\n]/i, '-') + '.xls'}\""
            response.write(xls) # NOTE: could this use streaming to start downloading quicker?

          rescue Sequel::DatabaseError => e
            view(inline: <<-EOS)
            <p style='color:red;'>There is a problem with the SQL definition of this report:</p>
            <p>Report: <em>#{caption}</em></p>The error message is:
            <pre>#{e.message}</pre>
            <button class="pure-button" onclick="crossbeamsUtils.toggleVisibility('sql_code', this);return false">
              <i class="fa fa-info"></i> Toggle SQL
            </button>
            <pre id="sql_code" style="display:none;"><%= sql_to_highlight(@rpt.runnable_sql) %></pre>
            EOS
          end
        end
      end
    end
  end
end