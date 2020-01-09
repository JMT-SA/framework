# frozen_string_literal: true

# Base class for storing, reading and writing a hash of data for a user.
#
# Typical use is for "wizard" style actions where:
# - some data is stored for the user from the 1st POST.
# - each subsequent step (forward/back) modifies the data.
# - the final step persists the accumulated data.
class BaseStep
  # Create a step.
  #
  # @param user [User, OpenStruct] the user instance - must respond to "id".
  # @param step_key [symbol] the key name for this step. This is the key to the LocalStore associated with this step.
  # @param ip_address [string] the IP address of the client - also used as part of the LocalStore key.
  # @return [void]
  def initialize(user, step_key, ip_address = nil)
    @user = user
    @ip_address = ip_address
    @step_key = step_key # must be symbol
  end

  # Write a value to the store.
  #
  # @param value [hash, any basic data type] the current value of the step.
  # @return [void]
  def write(value)
    store = LocalStore.new(@user.id, @ip_address)
    store.write(@step_key, value)
  end

  # Read the current value from the store.
  #
  # @return [hash, any basic data type] the current value of the step.
  def read
    store = LocalStore.new(@user.id, @ip_address)
    store.read(@step_key)
  end

  # Merge a hash with the current value (which must be a hash).
  #
  # @param opts [hash] the new hash values to be merged.
  # @return [void]
  def merge(opts)
    write(read.merge(opts))
  end

  # Clear the step (deletes the key in the LocalStore)
  #
  # @return [void]
  def clear
    store = LocalStore.new(@user.id, @ip_address)
    store.delete(@step_key)
  end
end
