module UtilityFunctions
  module_function

  TIME_DAY = 60 * 60 * 24
  TIME_WEEK = 60 * 60 * 24 * 7

  def weeks_ago(anchor, no_weeks)
    raise ArgumentError unless no_weeks.positive?
    case anchor
    when Time
      anchor - (no_weeks * TIME_WEEK)
    when DateTime
      anchor - (no_weeks * 7)
    when Date
      anchor - (no_weeks * 7)
    else
      raise ArgumentError, "weeks_ago: #{anchor.class} is not a date or time"
    end
  end

  def weeks_since(anchor, no_weeks)
    raise ArgumentError unless no_weeks.positive?
    case anchor
    when Time
      anchor + (no_weeks * TIME_WEEK)
    when DateTime
      anchor + (no_weeks * 7)
    when Date
      anchor + (no_weeks * 7)
    else
      raise ArgumentError, "weeks_since: #{anchor.class} is not a date or time"
    end
  end

  def days_ago(anchor, no_days)
    raise ArgumentError unless no_days.positive?
    case anchor
    when Time
      anchor - (no_days * TIME_WEEK)
    when DateTime
      anchor - no_days
    when Date
      anchor - no_days
    else
      raise ArgumentError, "days_ago: #{anchor.class} is not a date or time"
    end
  end

  def days_since(anchor, no_days)
    raise ArgumentError unless no_days.positive?
    case anchor
    when Time
      anchor + (no_days * TIME_WEEK)
    when DateTime
      anchor + no_days
    when Date
      anchor + no_days
    else
      raise ArgumentError, "days_since: #{anchor.class} is not a date or time"
    end
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
