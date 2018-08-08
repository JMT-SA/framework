source 'https://rubygems.org'
gem 'asciidoctor'
gem 'awesome_print'
gem 'bcrypt'
gem 'dotenv'
gem 'dry-inflector'
gem 'dry-struct'
gem 'dry-validation'
gem 'pg'
gem 'rack_csrf'
gem 'rake'
gem 'roda'
gem 'roda-symbolized_params'
gem 'rodauth'
gem 'rouge'
gem 'rubocop'
gem 'sass'
gem 'sequel'
gem 'sequel_postgresql_triggers'
gem 'thin'
gem 'tilt'
# gem 'tiny_tds' -- Required if dataminer has to run MSSqlServer reports.
gem 'yard'

gem 'crossbeams-dataminer', git: 'https://github.com/NoSoft-SA/crossbeams-dataminer.git'
gem 'crossbeams-label_designer', git: 'https://github.com/NoSoft-SA/crossbeams-label_designer.git'
# gem 'crossbeams-layout', git: 'https://github.com/NoSoft-SA/crossbeams-layout.git'
gem 'crossbeams-rack_middleware', git: 'https://github.com/NoSoft-SA/crossbeams-rack_middleware.git'
gem 'roda-data_grid', git: 'https://github.com/NoSoft-SA/roda-data_grid.git'

# gem 'crossbeams-dataminer',           path: File.expand_path('../../crossbeams-dataminer', __FILE__)
# gem 'crossbeams-label_designer',      path: File.expand_path('../../crossbeams-label_designer', __FILE__)
gem 'crossbeams-layout',              path: File.expand_path('../crossbeams-layout', __dir__)
# gem 'crossbeams-rack_middleware',     path: File.expand_path('../../crossbeams-rack_middleware', __FILE__)
# gem 'roda-data_grid',                 path: File.expand_path('../roda-data_grid', __dir__)

group :test do
  gem 'minitest', '~>5.11'
  gem 'minitest-hooks', '1.4.2'
  gem 'minitest-rg'
  gem 'minitest-stub_any_instance', '~>1.0.1'
  gem 'mocha', '~>1.5'
  gem 'rack-test'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-chruby'
  gem 'capistrano-passenger', '>= 0.1.1'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-clipboard'
  gem 'pry-doc'
  gem 'rack-console'
  gem 'rerun'
end
