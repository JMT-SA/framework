# frozen_string_literal: true

require_relative 'config/environment'

require 'bundler'
Bundler.require(:default, ENV.fetch('RACK_ENV', 'development'))

require './lib/types_for_dry'
require './lib/crossbeams_responses'
require './lib/base_repo'
require './lib/base_interactor'
require './lib/base_service'
require './lib/local_store' # Will only work for processes running from one dir.
require './lib/ui_rules'
require './lib/library_versions'
require './lib/dataminer_connections'
Dir['./helpers/**/*.rb'].each { |f| require f }
Dir['./lib/applets/*.rb'].each { |f| require f }

ENV['ROOT'] = File.dirname(__FILE__)
ENV['VERSION'] = File.read('VERSION')
ENV['GRID_QUERIES_LOCATION'] ||= File.expand_path('grid_definitions/dataminer_queries', __dir__)

# -------------------------------
# START OF TCP SERVER CODE
# -------------------------------
require 'socket'
# Dir['./tcp_routes/**/*.rb'].each { |f| require f } # to load the tcp routing logic...
puts 'Starting the server and awaiting connections.'
server = TCPServer.new(2626)

loop do
  Thread.fork(server.accept) do |client|
    request = client.gets.chomp
    puts request # route_handler::action::params (maybe format too? (xml/json/html/whatever)
    route, action, params = request.split('::') # --- also userID?
    # load a route_handler for the request.
    # Object.const_get("#{route.to_s.split('_').map(&:capitalize).join}TcpRoute").new(action, params).call -- or something like this...
    # inflector = Dry::Inflector.new
    # Object.const_get(inflector.classify("#{route}TcpRoute")).new(action, params).call -- or something like this...

    repo = SecurityApp::SecurityGroupRepo.new
    ids = repo.select_values('SELECT id FROM security_groups')
    grp = repo.find_security_group(ids.sample)

    client.puts("Route  : #{route}", "Action : #{action}", "Params : #{params.split(',').inspect}", "FROM DB: #{grp.security_group_name}", 'All Done!')
    client.close
  end
end
