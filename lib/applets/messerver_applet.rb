# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/messerver/repositories/*.rb"].sort.each { |f| require f }

module MesServerApp
end
