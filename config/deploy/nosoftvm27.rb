# VM instance at NoSoft offices
server '192.168.50.27', user: 'nsld', roles: %w[app db web]
set :deploy_to, '/home/nsld/pack_materials'
# set :default_env, 'PASSENGER_INSTANCE_REGISTRY_DIR' => '/var/run/passenger-instreg'
