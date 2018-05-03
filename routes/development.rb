# frozen_string_literal: true

Dir['./routes/development/*.rb'].each { |f| require f }

class Framework < Roda
  route('development') do |r|
    store_current_functional_area('development')
    r.multi_route('development')
  end
end
