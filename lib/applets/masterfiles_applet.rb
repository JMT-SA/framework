Dir['./lib/masterfiles/entities/*.rb'].each { |f| require f }
Dir['./lib/masterfiles/interactors/*.rb'].each { |f| require f }
Dir['./lib/masterfiles/repositories/*.rb'].each { |f| require f }
Dir['./lib/masterfiles/ui_rules/*.rb'].each { |f| require f }
Dir['./lib/masterfiles/validations/*.rb'].each { |f| require f }
Dir['./lib/masterfiles/views/**/*.rb'].each { |f| require f }
Dir['./lib/masterfiles/interactors/**/*.rb'].each { |f| require f }
