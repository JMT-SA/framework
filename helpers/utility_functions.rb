module UtilityFunctions
  module_function

  TIME_DAY = 60 * 60 * 24
  TIME_WEEK = 60 * 60 * 24 * 7

  def weeks_ago(anchor, no_weeks)
    change_weeks(anchor, no_weeks, -1)
  end

  def weeks_since(anchor, no_weeks)
    change_weeks(anchor, no_weeks, 1)
  end

  def days_ago(anchor, no_days)
    change_days(anchor, no_days, -1)
  end

  def days_since(anchor, no_days)
    change_days(anchor, no_days, 1)
  end

  def change_weeks(anchor, no_weeks, up_down)
    raise ArgumentError unless no_weeks.positive?

    case anchor
    when Time
      anchor + (no_weeks * TIME_WEEK * up_down)
    when DateTime
      anchor + (no_weeks * 7 * up_down)
    when Date
      anchor + (no_weeks * 7 * up_down)
    else
      raise ArgumentError, "change_weeks: #{anchor.class} is not a date or time"
    end
  end

  def change_days(anchor, no_days, up_down)
    raise ArgumentError unless no_days.positive?

    case anchor
    when Time
      anchor + (no_days * TIME_DAY * up_down)
    when DateTime
      anchor + (no_days * up_down)
    when Date
      anchor + (no_days * up_down)
    else
      raise ArgumentError, "change_days: #{anchor.class} is not a date or time"
    end
  end

  def ip_from_uri(ip_or_address)
    uri = URI.parse(ip_or_address)
    uri.host || uri.to_s
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

  # Commas as thousands separators for numbers.
  #
  # @param value [numeric] the number to be formatted.
  # @param symbol [string] the symbol (R/$ etc) to place on the left. Default is blank.
  # @param delimiter [string] the delimiter between groups of 3. Default is comma.
  # @param no_deciamls [integer] the number of decimals to display. Default is 2.
  # @return [String] the number with commas after every three digits.
  def delimited_number(value, symbol: '', delimiter: ',', no_decimals: 2)
    val      = value.nil? ? 0.0 : value
    parts    = format("#{symbol}%.#{no_decimals}f", val).split('.')
    parts[0] = parts.first.reverse.gsub(/([0-9]{3}(?=([0-9])))/, "\\1#{delimiter}").reverse
    parts.join('.')
  end

  # Takes a Numeric and returns a string without trailing zeroes.
  # Example:
  #     6.03 => "6.03".
  #     6.0  => "6".
  # @param numeric_value [numeric] the number to be displayed.
  # @return [String] the number with or without decimals.
  def format_without_trailing_zeroes(numeric_value)
    s = format('%<num>f', num: numeric_value)
    i = s.to_i
    f = s.to_f
    i == f ? i.to_s : f.to_s
  end

  # Deep merge for two hashes
  #
  # @param left [hash] the "base" hash
  # @param right [hash] the "additional" hash
  def merge_recursively(left, right)
    left.merge(right) { |_, a_item, b_item| a_item.is_a?(Hash) ? merge_recursively(a_item, b_item) : b_item }
  end

  # Change string keys in a nested hash into symbol keys.
  #
  # @param hash [hash] the hash with keys to symbolize.
  # @return [hash]
  def symbolize_keys(hash)
    if hash.is_a?(Hash)
      Hash[
        hash.map do |k, v|
          [k.respond_to?(:to_sym) ? k.to_sym : k, symbolize_keys(v)]
        end
      ]
    else
      hash
    end
  end

  def stringify_keys(hash)
    if hash.is_a?(Hash)
      Hash[
        hash.map do |k, v|
          [k.respond_to?(:to_s) ? k.to_s : k, stringify_keys(v)]
        end
      ]
    else
      hash
    end
  end
end
