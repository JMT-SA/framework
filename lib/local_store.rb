# frozen_string_literal: true

class LocalStore
  def initialize(user_id)
    FileUtils.mkpath(File.join(ENV['ROOT'], 'tmp', 'pstore'))
    @user_id = user_id
    @store = PStore.new(filename)
  end

  def read_once(key)
    @store.transaction { @store.delete(key) }
  end

  def read(key, default_value = nil)
    if default_value.nil?
      @store.transaction { @store[key] }
    else
      @store.transaction { @store.fetch(key, default_value) }
    end
  end

  def write(key, value)
    @store.transaction { @store[key] = value }
  end

  def delete(key)
    @store.transaction { @store.delete(key) }
  end

  def destroy
    File.delete(filename)
  end

  private

  def filename
    File.join(ENV['ROOT'], 'tmp', 'pstore', "usr_#{@user_id}")
  end
end
