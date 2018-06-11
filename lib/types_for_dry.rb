# frozen_string_literal: true

# Custom types to be used in dry-validation forms.
module Types
  include Dry::Types.module

  # Strips leading and trailing spaces from the input string.
  # Returns nil if the new result is blank.
  # Non-string input (including nil) passes through to be handled by the dry-validation schema.
  StrippedString = Types::String.constructor do |str|
    if str&.is_a?(::String)
      newstr = str.strip.chomp
      newstr.empty? ? nil : newstr
    else
      str
    end
  end

  # Turns an array of strings into an array of integers.
  # Blank elements are returned as nil.
  # Non-integers pass through to be handled by the dry-validation schema.
  IntArray = Types::Array.constructor do |elements|
    if elements
      elements.map do |element|
        if element&.is_a?(::String)
          next nil if element.empty?
          element.to_i.to_s == element ? element.to_i : element
        else
          element
        end
      end
    else
      elements
    end
  end

  # Turns a comma separated string of integers into an array.
  # Values are translated to Integers via ruby, this will throw an exception if it is invalid
  # Non-integers pass through to be handled by the dry-validation schema.
  ArrayFromString = Types::String.constructor do |str|
    array = str == '' ? [] : str.split(',')
    array.map { |val| Integer(val) }
  rescue StandardError
    str
  end
end
