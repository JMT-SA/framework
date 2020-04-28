root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/users/entities/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/users/repositories/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/users/validations/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/users/views/*.rb"].sort.each { |f| require f }
