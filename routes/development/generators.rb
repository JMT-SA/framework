# frozen_string_literal: true

class Framework < Roda
  route 'generators', 'development' do |r| # rubocop:disable Metrics/BlockLength
    # SCAFFOLDS
    # --------------------------------------------------------------------------
    r.on 'scaffolds' do
      r.on 'new' do    # NEW
        show_page { Development::Generators::Scaffolds::New.call }
      end

      r.on 'save_snippet' do
        FileUtils.mkpath(File.join(ENV['ROOT'], File.dirname(params[:snippet][:path])))
        File.open(File.join(ENV['ROOT'], params[:snippet][:path]), 'w') do |file|
          file.puts Base64.decode64(params[:snippet][:value])
        end
        { flash: { notice: "Saved file `#{params[:snippet][:path]}`" } }.to_json
      end

      r.post do        # CREATE
        contract = DevelopmentApp::ScaffoldNewContract.new
        res = contract.call(params[:scaffold] || {})
        if res.success?
          result = DevelopmentApp::GenerateNewScaffold.call(res.to_h, request.roda_class)
          show_page { Development::Generators::Scaffolds::Show.call(result) }
        else
          show_page { Development::Generators::Scaffolds::New.call(params[:scaffold], res.errors.to_h) }
        end
      end

      r.on 'table_changed' do
        json_replace_input_value('scaffold_short_name', params[:changed_value])
      end
    end

    r.on 'script_scaffolds' do
      r.on 'new' do    # NEW
        show_page { Development::Generators::ScriptScaffolds::New.call }
      end

      r.post do        # CREATE
        res = DevelopmentApp::ScriptScaffoldNewSchema.call(params[:scaffold] || {})
        if res.success?
          result = DevelopmentApp::GenerateNewScriptScaffold.call(res)
          show_page { Development::Generators::ScriptScaffolds::Show.call(result) }
        else
          show_page { Development::Generators::ScriptScaffolds::New.call(params[:scaffold], res.errors.to_h) }
        end
      end
    end

    # GENERAL
    # --------------------------------------------------------------------------
    r.on 'email_test' do
      r.get do
        show_page { Development::Generators::General::Email.call }
      end
      r.post do
        opts = {
          to: params[:mail][:to],
          subject: params[:mail][:subject],
          body: params[:mail][:body]
        }
        opts[:cc] = params[:mail][:cc] if params[:mail][:cc]
        DevelopmentApp::SendMailJob.enqueue(opts)
        show_page_success('Added email-sending job to the queue')
      end
    end
  end
end
