# frozen_string_literal: true

Dir['./routes/pack_material/*.rb'].sort.each { |f| require f }

class Framework < Roda
  route('pack_material') do |r|
    store_current_functional_area('pack material')
    r.multi_route('pack_material')
  end
end
