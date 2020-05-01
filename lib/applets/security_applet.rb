# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/security/entities/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/security/interactors/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/security/repositories/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/security/ui_rules/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/security/validations/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/security/views/**/*.rb"].sort.each { |f| require f }

module SecurityApp
end
