# frozen_string_literal: true

Dir['./routes/settings/*.rb'].each { |f| require f }

class Framework < Roda
  route('settings') do |r|
    r.multi_route('settings')
  end
end
