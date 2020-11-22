module UtilityFunctions # rubocop:disable Metrics/ModuleLength
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

  # Wrap text every 120 characters - breaking on a word boundary.
  #
  # @param text [string] the long text to be wrapped.
  # @param width [integer] the number of characters per line. Default 120.
  # @return [string] the input text with newlines at each wrap position.
  def wrapped_text(text, width = 120)
    ar = text.is_a?(Array) ? text : text.split("\n")
    ar.map { |a| a.scan(/\S.{0,#{width - 2}}\S(?=\s|$)|\S+/).join("\n") }.join("\n")
  end

  # Wrap SQL every 120 characters - breaking on a word boundary.
  # Ensure certain SQL keywords start on a new line.
  #
  # @param sql [string] the SQL to be wrapped.
  # @param width [integer] the number of characters per line. Default 120.
  # @return [string] the input SQL with newlines at each wrap position.
  def wrapped_sql(sql, width = 120)
    ar = sql.gsub(/from /i, "\nFROM ").gsub(/where /i, "\nWHERE ").gsub(/values /i, "\nVALUES ").gsub(/(left outer join |left join |inner join |join )/i, "\n\\1").split("\n")
    wrapped_text(ar, width)
  end

  # If a string contains a number in scientific notation format, return it formatted as a float.
  # e.g. 3.4e2 => 340.0
  # If the value is not a string, returns the value as is.
  # @param val [string,any] input value
  # @return [string,any]
  def scientific_notation_to_s(val)
    val.is_a?(String) && val.match?(/^-?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+)$/) ? BigDecimal(val).to_s('F') : val
  end

  # Commas as thousands separators for numbers.
  #
  # @param value [numeric] the number to be formatted.
  # @param symbol [string] the symbol (R/$ etc) to place on the left. Default is blank.
  # @param delimiter [string] the delimiter between groups of 3. Default is comma.
  # @param no_decimals [integer] the number of decimals to display. Default is 2.
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
    elsif hash.is_a?(Array)
      hash.map { |a| symbolize_keys(a) }
    else
      hash
    end
  end

  # Change keys in a nested hash into string keys.
  #
  # @param hash [hash] the hash with keys to stringify.
  # @return [hash]
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

  # Validate that an id is not longer than the maximum database integer value.
  #
  # @param colname [symbol] the name of the column.
  # @param value [string] the id value.
  # @return [Dry::Schema::Result] the validation result.
  def validate_integer_length(colname, value)
    raise ArgumentError, "#{self.class.name}: colname #{colname} must be a Symbol" unless colname.is_a?(Symbol)

    Dry::Schema.Params do
      required(colname).filled(:integer, lt?: AppConst::MAX_DB_INT)
    end.call(colname => value)
  end

  # Calculate the 4-digit pick ref:
  #
  # 1: Second digit of the ISO week
  # 2: day of the week (Mon = 1, Sun = 7)
  # 3: Packhouse number
  # 4: First digit of the ISO week
  #
  # @param packhouse_no [integer,string] the packhouse number - must be a single character.
  # @return [string] the pick ref for today.
  def calculate_pick_ref(packhouse_no, for_date: Date.today)
    raise ArgumentError, "Pick ref calculation: Packhouse number #{packhouse_no} is invalid - it must be a single character." unless packhouse_no.to_s.length == 1

    iso_week1, iso_week2 = for_date.strftime('%V').split(//).reverse

    "#{iso_week1}#{for_date.strftime('%u')}#{packhouse_no}#{iso_week2}"
  end

  # Humanize bytes as Kb/Mb etc.
  # From: https://stackoverflow.com/a/47486815/168006
  #
  # @param size [integer] the size in bytes
  # @return [string] the human-readable version of the size
  def filesize(size) # rubocop:disable Metrics/AbcSize
    units = %w[B KiB MiB GiB TiB Pib EiB]

    return '0.0 B' if size.zero?

    exp = (Math.log(size) / Math.log(1024)).to_i
    exp += 1 if size.to_f / 1024**exp >= 1024 - 0.05
    exp = 6 if exp > 6

    format('%<size>.1f %<unit>s', size: size.to_f / 1024**exp, unit: units[exp])
  end

  # Check if the mime type of a file is XML
  #
  # @param file_path [string] the file
  # @return [boolean] - true if the file is an XML file
  def xml_file?(file_path)
    typ = IO.popen(['file', '--brief', '--mime-type', file_path], in: :close, err: :close) { |io| io.read.chomp }
    %w[application/xml text/xml].include?(typ)
  end

  # Takes a string and returns an array from text split on commas and new lines.
  #
  # @param  in_string [string] string to be parsed.
  # @return [array]
  def parse_string_to_array(in_string)
    clean_string = in_string.split(/\n|,/).map(&:strip).reject(&:empty?)
    clean_string.map { |x| x.gsub(/['"]/, '') }
  end

  # Returns the non numeric elements of an array of strings.
  #
  # @param  in_array [array] array to be checked
  # @return [array] which might be empty.
  def non_numeric_elements(in_array)
    Array(in_array).reject { |x| x.match(/\A\d+\Z/) }
  end

  # Randomize a URL by adding a queryparam based on current time.
  #
  # @param path [string] the URL path
  # @return [string] the path with "?seq=nnn" appended. (nnn is time in seconds)
  def cache_bust_url(path)
    "#{path}?seq=#{Time.now.nsec}"
  end

  # Render HTML to display a loading graphic - optionally with message.
  #
  # @param message [string] optional message to display.
  # @return [string] rendered HTML
  def loading_message(message = nil)
    Crossbeams::Layout::LoadingMessage.new(caption: message, wrap_for_centre: true).render
  end

  # Render an SVG icon.
  #
  # @param name [symbol] the name of the icon to render.
  # @return [string] rendered SVG.
  def icon(name, options = {})
    Crossbeams::Layout::Icon.new(name, options).render
  end
end
