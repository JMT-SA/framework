module UtilityFunctions
  module_function

  # Camelize a string (another_string => AnotherString)
  def camelize(str)
    inflector = Dry::Inflector.new
    inflector.camelize(str)
  end

  # Take a plural string and make a singular version.
  def simple_single(str)
    inflector = Dry::Inflector.new
    inflector.singularize(str)
  end

  def newline_and_spaces(count)
    "\n#{' ' * count}"
  end

  def comma_newline_and_spaces(count)
    ",\n#{' ' * count}"
  end

  def spaces_from_string_lengths(initial_spaces, *strings)
    ' ' * ((initial_spaces || 0) + strings.sum(&:length))
  end
end
