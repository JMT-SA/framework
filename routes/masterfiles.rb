# frozen_string_literal: true

Dir['./routes/masterfiles/*.rb'].each { |f| require f }

class Framework < Roda
  route('masterfiles') do |r|
    r.multi_route('masterfiles')
  end
end

