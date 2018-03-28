module DataminerHelpers
  # Syntax highlighting for SQL using Rouge.
  #
  # @param sql [String] the sql.
  # @return [String] HTML styled for syntax highlighting.
  def sql_to_highlight(sql)
    # wrap sql @ 120
    width = 120
    ar = sql.gsub(/from /i, "\nFROM ").gsub(/where /i, "\nWHERE ").gsub(/(left outer join |left join |inner join |join )/i, "\n\\1").split("\n")
    wrapped_sql = ar.map { |a| a.scan(/\S.{0,#{width - 2}}\S(?=\s|$)|\S+/).join("\n") }.join("\n")

    theme     = Rouge::Themes::Github.new
    formatter = Rouge::Formatters::HTMLInline.new(theme)
    lexer     = Rouge::Lexers::SQL.new
    formatter.format(lexer.lex(wrapped_sql))
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
