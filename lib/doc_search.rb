# frozen_string_literal: true

class DocSearch
  attr_reader :doc_type, :term, :out

  def initialize(doc_type)
    @doc_type = doc_type
  end

  def search_for(param_term)
    @term = param_term.strip
    @out = build_results

    <<~HTML
      #{result_header}
      <div class="db">
        #{result_contents}
        <hr class="blue"></div>
      </div>
    HTML
  end

  private

  def search_path
    case doc_type
    when :help
      "#{ENV['ROOT']}/help/**/*.adoc"
    when :devdoc
      "#{ENV['ROOT']}/developer_documentation/*.adoc"
    end
  end

  def process_line(line)
    (line.chomp || '').gsub('<', '&lt;').gsub('>', '&gt;').gsub(/(#{term})/i, '<span class="red b bg-light-yellow">\1</span>')
  end

  def build_results
    return {} if term.empty?

    out = {}
    Dir.glob(search_path).each do |filename|
      lines = File.foreach(filename).grep(/#{term}/i)
      next if lines.empty?

      out[filename] = []
      lines.each do |line|
        out[filename] << process_line(line)
      end
    end
    out
  end

  def back_link
    case doc_type
    when :help
      '<a href="/help/app/index">Back to help index</a>'
    when :devdoc
      '<a href="/developer_documentation/start.adoc">Back to documentation home</a>'
    end
  end

  def result_header
    got_res = out.empty? ? 'No s' : 'S'
    <<~HTML
      <div class="db f2 mt5">
        #{got_res}earch results for "<b>#{term}</b>"
      </div>
      <p>
        #{back_link}
      </p>
    HTML
  end

  def format_file_link(file)
    case doc_type
    when :help
      file.delete_prefix("#{ENV['ROOT']}/help/app/").delete_prefix("#{ENV['ROOT']}/help/system/").delete_suffix('.adoc').tr('_', ' ').tr('/', ':')
    when :devdoc
      file.delete_prefix("#{ENV['ROOT']}/developer_documentation/").delete_suffix('.adoc').tr('_', ' ')
    end
  end

  def result_contents
    out.map do |k, v|
      <<~STR
        <div class=\"mt3 lh-copy\">
          <a href=\"#{k.delete_prefix(ENV['ROOT'])}\" class=\"f3 link dim br2 ph3 pv2 dib white bg-dark-blue mb2\">
          #{Crossbeams::Layout::Icon.render(:back)} #{format_file_link(k)}
          </a>
          <br>
          #{v.join('<br>')}
      STR
    end.join('<hr class="blue"></div>')
  end
end
