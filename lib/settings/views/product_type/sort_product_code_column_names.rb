# frozen_string_literal: true

module Settings
  module Products
    module ProductType
      class SortProductCodeColumnNames
        def self.call(id)
          repo = ProductTypeRepo.new
          product_code_column_name_list = repo.product_code_column_name_list(id)

          layout = Crossbeams::Layout::Page.build do |page|
            page.form do |form|
              form.action "/labels/labels/labels/#{id}/apply_sub_labels"
              form.remote!
              form.add_text 'Drag and drop to set the Product code column order. Press submit to save the new order.'
              form.add_sortable_list('code_columns', product_code_column_name_list)
            end
          end

          layout
        end
      end
    end
  end
end
