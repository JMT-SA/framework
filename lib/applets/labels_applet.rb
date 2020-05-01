# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/labels/entities/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/labels/interactors/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/labels/repositories/*.rb"].sort.each { |f| require f }
# Dir["#{root_dir}/labels/services/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/labels/ui_rules/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/labels/validations/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/labels/views/**/*.rb"].sort.each { |f| require f }

module LabelApp
end
