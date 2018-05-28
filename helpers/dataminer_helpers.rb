module DataminerHelpers
  # Syntax highlighting for SQL using Rouge.
  #
  # @param sql [String] the sql.
  # @return [String] HTML styled for syntax highlighting.
  def sql_to_highlight(sql)
    ar = sql_add_newlines(sql_format_from_and_where(sql)).split("\n")
    wrapped_sql = ar.map { |a| wrap_line(a, 120) }
                    .reject(&:empty?)
                    .join("\n")

    theme     = Rouge::Themes::Github.new
    formatter = Rouge::Formatters::HTMLInline.new(theme)
    lexer     = Rouge::Lexers::SQL.new
    formatter.format(lexer.lex(wrapped_sql))
  end

  # Word-wrap a line of text.
  #
  # @param str [String] the line.
  # @param width [Integer] the position at which to wrap words.
  # @return [String] The line with newline characters inserted where appropriate.
  def wrap_line(str, width)
    str.scan(/\S.{0,#{width - 2}}\S(?=\s|$)|\S+/).join("\n")
  end

  # Add newlines to SQL before certain keywords.
  #
  # @param sql [String] the sql.
  # @return [String] SQL with newlines injected where appropriate.
  def sql_add_newlines(sql)
    key_phrases = ['left outer join',
                   'left join ',
                   'inner join ',
                   'join ',
                   'order by ',
                   'group by '].join('|')
    sql.gsub(/(#{key_phrases})/i, "\n\\1")
  end

  # Add newlines to SQL before from and where. Make uppercase.
  #
  # @param sql [String] the sql.
  # @return [String] SQL with newlines injected where appropriate.
  def sql_format_from_and_where(sql)
    sql.gsub(/from /i, "\nFROM ").gsub(/where /i, "\nWHERE ")
  end

  # Syntax highlighting for YAML using Rouge.
  #
  # @param yml [String] the yaml string.
  # @return [String] HTML styled for syntax highlighting.
  def yml_to_highlight(yml)
    theme     = Rouge::Themes::Github.new
    formatter = Rouge::Formatters::HTMLInline.new(theme)
    lexer     = Rouge::Lexers::YAML.new
    formatter.format(lexer.lex(yml))
  end

  # Remove artifacts from old dataminer WHERE clause specifications.
  #
  # @param sql [String] the sql to be cleaned.
  # @return [String] the sql with +paramname={paramname}+ artifacts removed.
  def clean_where(sql)
    rems = sql.scan(/\{(.+?)\}/).flatten.map { |s| "#{s}={#{s}}" }
    rems.each { |r| sql.gsub!(/and\s+#{r}/i, '') }
    rems.each { |r| sql.gsub!(r, '') }
    sql.sub!(/where\s*\(\s+\)/i, '')
    sql
  end
end
