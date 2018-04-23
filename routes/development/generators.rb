# frozen_string_literal: true

class Framework < Roda
  route 'generators', 'development' do |r|
    # SCAFFOLDS
    # --------------------------------------------------------------------------
    r.on 'scaffolds' do
      r.on 'new' do    # NEW
        show_page { Development::Generators::Scaffolds::New.call }
      end

      r.on 'save_snippet' do
        return_json_response
        FileUtils.mkpath(File.join(ENV['ROOT'], File.dirname(params[:snippet][:path])))
        File.open(File.join(ENV['ROOT'], params[:snippet][:path]), 'w') do |file|
          file.puts Base64.decode64(params[:snippet][:value])
        end
        { flash: { notice: "Saved file `#{params[:snippet][:path]}`" } }.to_json
      end

      r.post do        # CREATE
        res = DevelopmentApp::ScaffoldNewSchema.call(params[:scaffold] || {})
        errors = res.messages
        if errors.empty?
          result = GenerateNewScaffold.call(res.to_h, request.roda_class)
          show_page { Development::Generators::Scaffolds::Show.call(result) }
        else
          puts errors.inspect
          show_page { Development::Generators::Scaffolds::New.call(params[:scaffold], errors) }
        end
      end

      r.on 'table_changed' do
        json_replace_input_value('scaffold_short_name', params[:changed_value])
      end
    end
  end
end
