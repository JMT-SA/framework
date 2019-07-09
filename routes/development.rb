# frozen_string_literal: true

Dir['./routes/development/*.rb'].each { |f| require f }

class Framework < Roda
  route('development') do |r|
    store_current_functional_area('development')

    r.is 'grid_icons' do
      show_page { Development::Documentation::GridIcons.call }
    end
    r.is 'grid_column_icons' do
      show_page { Development::Documentation::GridColumnIcons.call }
    end
    r.is 'layout_icons' do
      show_page { Development::Documentation::LayoutIcons.call }
    end

    r.multi_route('development')
  end
end
