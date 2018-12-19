# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
# Dir["#{root_dir}/label_printing/entities/*.rb"].each { |f| require f }
Dir["#{root_dir}/label_printing/interactors/*.rb"].each { |f| require f }
# Dir["#{root_dir}/label_printing/repositories/*.rb"].each { |f| require f }
# Dir["#{root_dir}/label_printing/services/*.rb"].each { |f| require f }
# Dir["#{root_dir}/label_printing/ui_rules/*.rb"].each { |f| require f }
# Dir["#{root_dir}/label_printing/validations/*.rb"].each { |f| require f }
# Dir["#{root_dir}/label_printing/views/**/*.rb"].each { |f| require f }

module LabelPrintingApp
end
