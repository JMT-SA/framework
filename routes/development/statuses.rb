# frozen_string_literal: true

class Framework < Roda
  route 'statuses', 'development' do |r|
    # CURRENT STATUSES
    # --------------------------------------------------------------------------
    r.on 'show' do
      r.post do
        r.redirect "/development/statuses/show/#{params[:status][:table_name]}/#{params[:status][:row_data_id]}"
      end

      r.is do
        show_page { Development::Statuses::Status::Select.call }
      end

      r.on String, Integer do |table, id|
        show_partial_or_page(r) { Development::Statuses::Status::Show.call(table, id, remote: fetch?(r)) }
      end
    end
  end
end
