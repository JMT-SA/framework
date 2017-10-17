# frozen_string_literal: true

class Framework < Roda
  route 'generators', 'development' do |r|
    # SCAFFOLDS
    # --------------------------------------------------------------------------
    r.on 'scaffolds' do
      r.on 'new' do    # NEW
        begin
          # if authorised?('menu', 'new')
          show_page { Development::Generators::Scaffolds::New.call }
          # else
          #   show_unauthorised
          # end
          # Should lead to step 1, 2 etc.
        rescue StandardError => e
          handle_error(e)
        end
      end

      r.on 'save_snippet' do
        response['Content-Type'] = 'application/json'
        FileUtils.mkpath(File.dirname(params[:snippet][:path]))
        File.open(File.join(ENV['ROOT'], params[:snippet][:path]), 'w') do |file|
          file.puts Base64.decode64(params[:snippet][:value])
        end
        { flash: { notice: "Saved file `#{params[:snippet][:path]}`" } }.to_json
      end

      r.post do        # CREATE
        res = ScaffoldNewSchema.call(params[:scaffold] || {})
        errors = res.messages
        if errors.empty?
          result = GenerateNewScaffold.call(params[:scaffold])
          show_page { Development::Generators::Scaffolds::Show.call(result) }
        else
          puts errors.inspect
          show_page { Development::Generators::Scaffolds::New.call(params[:scaffold], errors) }
        end
      end
    end
  end
end
