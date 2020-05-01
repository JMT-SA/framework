# frozen_string_literal: true

class HelpIndexBuilder
  attr_reader :help_type

  def initialize(help_type)
    @help_type = help_type
  end

  def content
    hs = {}
    help_files.each do |group, file|
      hs[group] ||= []
      hs[group] << file
    end
    <<~HTML
      link:/help/#{opposite_type}/index[#{other_index_name} index page]

      #{build_entries(hs).join}
    HTML
  end

  private

  def opposite_type
    help_type == 'app' ? 'system' : 'app'
  end

  def other_index_name
    help_type == 'app' ? 'System' : 'Help'
  end

  def help_files
    Dir.glob("help/#{help_type}/**/*.adoc").map do |f|
      base = File.basename(f)
      group = f.delete_prefix("help/#{help_type}/").delete_suffix(base).chomp('/').capitalize
      [group, f]
    end
  end

  def build_entries(content)
    ar = []
    content.each_key do |group|
      ar << "\n== #{group}\n"
      content[group].each do |file|
        ar << "* link:/#{file}[#{File.basename(file).delete_suffix('.adoc').gsub('_', ' ').capitalize}]\n"
      end
    end
    ar
  end
end
