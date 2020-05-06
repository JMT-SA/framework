# Pack Materials at Kromco.
server '172.16.16.4', user: 'nsld', roles: %w[app db web]
set :deploy_to, '/home/nsld/pack_materials'
