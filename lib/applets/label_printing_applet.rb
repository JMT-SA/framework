# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)

# Pre-load included module:
require "#{root_dir}/label_printing/services/label_content.rb"

Dir["#{root_dir}/label_printing/services/*.rb"].sort.each { |f| require f }

module LabelPrintingApp
end
