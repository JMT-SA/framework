# frozen_string_literal: true

require './app_loader'

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
