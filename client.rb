$:.unshift File.join(Dir.pwd, 'models')
$:.unshift File.join(Dir.pwd, 'lib')

require 'listen'
require 'files'
require 'base64'
require 'yaml'
require 'config_manager'


def condition server_file, local_file
  file_version = ConfigManager.files_version[server_file.path]
  return_value = {}

  return_value[:server] = check_date_time server_file.last_update, file_version["server_last_update"]
  return_value[:local]  = check_date_time local_file.last_update, file_version["local_last_update"]

  return_value
end

def check_date_time date_time1, date_time2
  return 0 if date_time1 == date_time2
  return 1 if date_time1 >  date_time2
  return -1
end


def check(key, exists)
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
    local_file  = Files::LocalFile.find(key)
    server_file = Files::ServerFile.find(key)

    condition_values = condition(server_file, server_key)

    if condition_values[:server] == 0 && condition_values[:local] == 0
      # do nothing
    elsif condition_values[:server] == 1 && condition_values[:local] == 0
      server_file.download
    elsif condition_values[:server] == 0 && condition_values[:local] == 1
      # upload to server
    elsif condition_values[:server] == 1 && condition_values[:local] == 1
      # conflict
    else
      server_file.download
    end
  elsif !exists[:server] && !exists[:local] && exists[:version]
    # delete from version
  elsif exists[:server] && !exists[:local] && !exists[:version]
    # download to local
  elsif !exists[:server] && exists[:local] && !exists[:version]
    # upload to server
  elsif exists[:server] && exists[:local] && !exists[:version]
    # conflict
  elsif !exists[:server] && exists[:local] && exists[:version]
    #       | delete | upload to server | delete |
    # --------------------------------------------
    # local | match  | greater          | less   |
  elsif exists[:server] && !exists[:local] && exists[:version]
    #        | delete | download to local | delete |
    # ----------------------------------------------
    # server | match  | greater           | less   |
  else
    # NEVER WOULD HAVE HAPPENED
  end
end




def old_check server_file
  key         = server_file.key
  if ConfigManager.files_version[key] && ConfigManager.files_version[key]["server_last_update"] == server_files.last_update
    # do nothing
  elsif !ConfigManager.files_version[key] || (ConfigManager.files_version[key] && ConfigManager.files_version[key]["server_last_update"] < server_file.last_update)
    # download and replace client file from server
    server_file.download(true)

    local_file = Files::LocalFile.find(server_file.key)
    # update the files config with latest server_last_update date from server
    ConfigManager.update_files_version(key, "server_last_update", server_file.last_update)
    ConfigManager.update_files_version(key, "local_last_update", local_file.last_update)
  else
    raise "Your config seems to be inconsistent with the server"
  end
end

def check_all
  Files::ServerFile.all.each do |file|
    old_check file
  end
  ConfigManager.save_files_version
end

def check_server_file path
  begin
    server_file = Files::ServerFile.find(path)
    if server_file["last_update"] == ConfigManager.files_version[path]["server_last_update"]
      # your record is correct
    else
      # there are newer version on server
    end
  rescue ActiveResource::ResourceNotFound
    # file not on server
    # other client deleted the files from server?
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

