# frozen_string_literal: true

Dir['./routes/dataminer/*.rb'].each { |f| require f }

class Framework < Roda
  route('dataminer') do |r|
    r.multi_route('dataminer')
  end
end
