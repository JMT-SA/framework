# frozen_string_literal: true

class Framework < Roda
  route 'summary', 'pack_material' do
    show_page { PackMaterial::Summary::Show.call }
  end
end
