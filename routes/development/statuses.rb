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

    r.on 'list', String, Integer do |table, id|
      show_partial_or_page(r) { Development::Statuses::Status::List.call(table, id, remote: fetch?(r)) }
    end

    r.on 'detail', Integer do |id|
      show_partial_or_page(r) { Development::Statuses::Status::Detail.call(id, remote: fetch?(r)) }
    end

    r.on 'diff', Integer do |id|
      # Use LoggingInteractor for doing diffs from logged actions.
      interactor = DevelopmentApp::LoggingInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
      left, right = interactor.diff_action(id, from_status_log: true)
      show_partial { Development::Logging::LoggedAction::Diff.call(id, left, right) }
    end
  end
end
