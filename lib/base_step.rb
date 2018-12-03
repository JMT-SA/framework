# frozen_string_literal: true

class BaseStep
  def initialize(user, step_key)
    @user = user
    @step_key = step_key # must be symbol
  end

  def write(value)
    store = LocalStore.new(@user.id)
    store.write(@step_key, value)
  end

  def read
    store = LocalStore.new(@user.id)
    store.read(@step_key)
  end

  def merge(opts)
    write(read.merge(opts))
  end
end
