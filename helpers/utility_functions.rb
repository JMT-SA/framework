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
