# frozen_string_literal: true

Dir['./routes/dataminer/*.rb'].sort.each { |f| require f }

class Framework < Roda
  route('dataminer') do |r|
    store_current_functional_area('dataminer')
    r.multi_route('dataminer')
  end
end
