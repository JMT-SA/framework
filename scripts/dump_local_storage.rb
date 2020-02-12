# frozen_string_literal: true

class DumpLocalStorage < BaseScript
  require 'pstore'

  def run
    cache_files = File.join(root_dir, 'tmp/pstore/*')
    user_cache
    puts '-----------------------------'
    puts 'Non-empty local storage files'
    puts '-----------------------------'
    puts ''
    Dir.glob(cache_files).each do |f|
      report_file(f) if File.file?(f)
    end

    ok_response
  end

  def report_file(file) # rubocop:disable Metrics/AbcSize
    st = PStore.new(file)
    printed = false
    ar = ["FILE: #{file}", "TIME: #{File.mtime(file)}", file_owner(File.basename(file))]
    st.transaction(true) do
      st.roots.each do |nm|
        printed = true
        if st[nm].is_a?(Hash) || st[nm].is_a?(Array)
          ar << "#{nm} ::"
          ar << st[nm].inspect
        else
          ar << "#{nm} :: #{st[nm]}"
        end
      end
    end
    puts ar.compact.push("---\n\n").join("\n") if printed
  end

  def user_cache
    @users = Hash[DB[:users].select_map(%i[id user_name])]
  end

  def file_owner(file)
    return nil unless file.start_with?('usr_')

    id, ip = file.delete_prefix('usr_').split('_')
    ar = []
    ar << @users[id.to_i] if id
    ar << ip.gsub('-', '.') if ip
    "USER: #{ar.compact.join(' - ')}"
  end
end
