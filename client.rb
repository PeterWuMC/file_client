$:.unshift File.join(Dir.pwd, 'models')
$:.unshift File.join(Dir.pwd, 'lib')

require 'listen'
require 'files'
require 'base64'
require 'yaml'
require 'config_manager'


def condition server_file, local_file, file_version
  return_value = {}

  if file_version
    return_value[:server] = server_file ? check_date_time(server_file.last_update, file_version["server_last_update"]) : false
    return_value[:local]  = local_file ? check_date_time(local_file.last_update, file_version["local_last_update"]) : false
  end

  return_value
end

def check_date_time date_time1, date_time2
  return 0     if date_time1 == date_time2
  return 1     if date_time1 >  date_time2
  return -1
end


def check(key, exists)
  local_file   = Files::LocalFile.find(key)
  server_file  = Files::ServerFile.find(key)
  file_version = ConfigManager.files_version[key]

  puts Base64.strict_decode64(key)

  condition_values = condition(server_file, local_file, file_version)
  #         | 1 | delete from version | download to local | upload to server | conflict | upload to server* | delete from server* | never |
  # ---------------------------------------------------------------------------------------------------------------------------------------
  # server  | T | F                   | T                 | F                | T        | F                 | T                   | F     |
  # local   | T | F                   | F                 | T                | T        | T                 | F                   | F     |
  # version | T | T                   | F                 | F                | F        | T                 | T                   | F     |
  if exists[:server] && exists[:local] && exists[:version]
    #      1 | nothing | download to local | upload to server | conflict | download to local |
    # ----------------------------------------------------------------------------------------
    # server | match   | greater           | match            | greater  | less*             |
    # local  | match   | match             | greater          | greater  | less*             |
    if condition_values[:server] == 0 && condition_values[:local] == 0
      # do nothing
    elsif condition_values[:server] == 1 && condition_values[:local] == 0
      server_file.download
    elsif condition_values[:server] == 0 && condition_values[:local] == 1
      local_file.upload
    elsif condition_values[:server] == 1 && condition_values[:local] == 1
      raise "conflict"
    else
      server_file.download
    end
  elsif !exists[:server] && !exists[:local] && exists[:version]
    ConfigManger.delete_file_version key
      ConfigManger.save_files_version
  elsif exists[:server] && !exists[:local] && !exists[:version]
    server_file.download
  elsif !exists[:server] && exists[:local] && !exists[:version]
    local_file.upload
  elsif exists[:server] && exists[:local] && !exists[:version]
    raise "conflict"
  elsif !exists[:server] && exists[:local] && exists[:version]
    #       | delete | upload to server | delete |
    # --------------------------------------------
    # local | match  | greater          | less   |
    if condition_values[:client] == 0 || condition_values[:client] == -1
      FileManager.delete(:client, local_file.path)
      ConfigManger.delete_file_version key
      ConfigManger.save_files_version
    elsif condition_values[:client] == 1
      local_file.upload
    end
  elsif exists[:server] && !exists[:local] && exists[:version]
    #        | delete | download to local | delete |
    # ----------------------------------------------
    # server | match  | greater           | less   |
    if condition_values[:server] == 0 || condition_values[:server] == -1
      server_file.delete
      ConfigManger.delete_file_version key
      ConfigManger.save_files_version
    elsif condition_value[:server] == 1
      server_file.download
    end
  else
    # NEVER WOULD HAVE HAPPENED
  end
end



def check_all
  server_files  = Files::ServerFile.all.map(&:key)
  local_files   = Files::LocalFile.all.map(&:key)
  files_version = ConfigManager.files_version.keys

  all = server_files | local_files | files_version

  while all.size > 0
    key = all.pop
    check(key, {server: server_files.include?(key), local: local_files.include?(key), version: files_version.include?(key)})
  end
end

def monitor_files
  Thread.start do
    Listen.to("/Users/pwu/Workarea/tmp/abc") do |modified, added, removed|
      if !modified.empty?
        puts "this file is modified: #{modified}"
      end

      if !added.empty?
        puts "this file is added: #{added}"
      end

      if !removed.empty?
        puts "this file is removed: #{removed}"
      end
    end
  end
end

check_all

