# frozen_string_literal: true

Dir['./routes/security/*.rb'].sort.each { |f| require f }

class Framework < Roda
  route('security') do |r|
    store_current_functional_area('security')
    r.multi_route('security')
  end
end
