Dir['./lib/development/entities/*.rb'].each { |f| require f }
Dir['./lib/development/repositories/*.rb'].each { |f| require f }
Dir['./lib/development/services/*.rb'].each { |f| require f }
Dir['./lib/development/ui_rules/*.rb'].each { |f| require f }
Dir['./lib/development/validations/*.rb'].each { |f| require f }
Dir['./lib/development/views/**/*.rb'].each { |f| require f }
