# frozen_string_literal: true

class LocalStore
  def initialize(user_id, ip = nil)
    FileUtils.mkpath(File.join(ENV['ROOT'], 'tmp', 'pstore'))
    @user_id = user_id
    @ip = ip
    @store = PStore.new(filename, true)
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
    File.join(ENV['ROOT'], 'tmp', 'pstore', "usr_#{@user_id}#{ip_suffix}")
  end

  def ip_suffix
    return '' if @ip.nil?

    "_#{@ip.tr('.', '-')}"
  end
end
