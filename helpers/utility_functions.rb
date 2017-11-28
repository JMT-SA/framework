module UtilityFunctions
  module_function

  # Camelize a string (another_string => AnotherString)
  def camelize(s)
    s.sub(/^[a-z\d]*/) { $&.capitalize }.gsub(%r{(?:_|(\/))([a-z\d]*)}) do
      "#{Regexp.last_match[1]}#{Regexp.last_match[2].capitalize}"
    end.gsub('/', '::')
  end

  # Take a plural string and make a singular version.
  # NB. This is NOT foolproof.
  def simple_single(s)
    return 'person' if s == 'people'

    if s.end_with?('ies')
      s.sub(/ies$/, 'y')
    elsif s.end_with?('dresses')
      s.sub(/es$/, '')
    else
      s.sub(/s$/, '')
    end
  end

  def newline_and_spaces(no)
    "\n#{' ' * no}"
  end

  def comma_newline_and_spaces(no)
    ",\n#{' ' * no}"
  end

  def spaces_from_string_lengths(initial_spaces, *strings)
    ' ' * ((initial_spaces || 0) + strings.sum(&:length))
  end
end
