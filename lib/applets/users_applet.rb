root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/users/entities/*.rb"].each { |f| require f }
Dir["#{root_dir}/users/repositories/*.rb"].each { |f| require f }
Dir["#{root_dir}/users/validations/*.rb"].each { |f| require f }
Dir["#{root_dir}/users/views/*.rb"].each { |f| require f }
