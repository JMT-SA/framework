# frozen_string_literal: true

class LocalStore
  def initialize(user_id)
    FileUtils.mkpath(File.join(ENV['ROOT'], 'tmp', 'pstore'))
    @store = PStore.new(File.join(ENV['ROOT'], 'tmp', 'pstore', "usr_#{user_id}"))
  end

  def read_once(key)
    @store.transaction { @store[key]; @store.delete(key); }
  end

  def write(key, value)
    @store.transaction { @store[key] = value }
  end
end
