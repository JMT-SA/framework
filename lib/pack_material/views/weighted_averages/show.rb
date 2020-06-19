# frozen_string_literal: true

module PackMaterial
  module Transactions
    module WeightedAverages
      class Show
        def self.call
          layout = Crossbeams::Layout::Page.build do |page|
            page.section do |section|
              section.add_grid('weighted_averages_records',
                               '/pack_material/transactions/weighted_averages/records',
                               caption: 'Weighted Averages Records')
            end
          end

          layout
        end
      end
    end
  end
end
