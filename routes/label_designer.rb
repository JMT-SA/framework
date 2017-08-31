class Framework < Roda
  route('label_designer') do |r|
    r.root do
      view(inline: label_designer_page, layout: 'layout_label')
    end

    r.on :id do |id|
      view(inline: label_designer_page(id), layout: 'layout_label')
    end
  end

  def label_designer_page(file_name = nil)
    page = Crossbeams::LabelDesigner::Page.new(file_name)
    # page.json_load_path = '/load_label_via_json' # Override config just before use.
    html = page.render
    css  = page.css
    js   = page.javascript

    <<-EOC
    #{html}
    <% content_for :late_style do %>
      #{css}
    <% end %>
    <% content_for :late_javascript do %>
      #{js}
    <% end %>
    EOC
  end
end
