# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
class Framework < Roda
  route('help') do |r|
    r.on 'system' do
      r.on 'index' do
        index = HelpIndexBuilder.new('system')
        view(inline: render_asciidoc(index.content, '/help/system_images'), layout: 'layout_help')
      end

      header = <<~STR
        link:/help/system/index[System index page]

      STR
      file = r.remaining_path
      help = File.read(File.join(ENV['ROOT'], 'help/system', "#{file.chomp('.adoc')}.adoc"))
      view(inline: render_asciidoc(header + help, '/help/system_images'), layout: 'layout_help')
    end

    r.on 'app' do
      r.on 'index' do
        index = HelpIndexBuilder.new('app')
        view(inline: render_asciidoc(index.content, '/help/app_images'), layout: 'layout_help')
      end

      header = <<~STR
        link:/help/app/index[Help index page]

      STR
      file = r.remaining_path
      help = File.read(File.join(ENV['ROOT'], 'help/app', "#{file.chomp('.adoc')}.adoc"))
      view(inline: render_asciidoc(header + help, '/help/app_images'), layout: 'layout_help')
    end

    r.on 'search' do
      search = DocSearch.new(:help)
      content = search.search_for(params[:search_term])
      @search_page = true
      view(inline: content, layout: 'layout_help')
    end
  end
end
# rubocop:enable Metrics/BlockLength
