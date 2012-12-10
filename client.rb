$:.unshift File.join(Dir.pwd, 'models')
$:.unshift File.join(Dir.pwd, 'lib')

require 'listen'
require 'files'
require 'base64'
require 'yaml'
require 'config_manager'


def condition server_file, local_File
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

def check server_file

  local_File = Files::LocalFile.find(server_file.path)

  if ConfigManager.files_version[path]
    # if the files version exists
    #        | nothing | download to local | upload to server | conflict | download to local |
    # ----------------------------------------------------------------------------------------
    # local  | match   | match             | greater          | greater  | less*             |
    # server | match   | greater           | match            | greater  | less*             |
    condition_values = condition(server_file, local_file)

    if condition_values[:server] == 0 && condition_values[:local] == 0
      # does nothing
    elsif condition_values[:server] == 1 && condition_values[:local] == 0
      server_file.download
    elsif condition_values[:server] == 0 && condition_values[:local] == 1
      # upload to server
    elsif condition_values[:server] == 1 && condition_values[:local] == 1
      # conflict
    else
      server_file.download
    end 
  else
    # if the file does not exists on the files version
    #        | upload to server | conflict | download to local | never |
    # ------------------------------------------------------------------
    # local  | Y                | Y        | N                 | N     |
    # server | N                | Y        | Y                 | N     |
    if server_file && local_file
      # conflict
    end 
  end


  path        = server_file.path
  if ConfigManager.files_version[path] && ConfigManager.files_version[path]["server_last_update"] == server_files.last_update
    # do nothing
  elsif !ConfigManager.files_version[path] || (ConfigManager.files_version[path] && ConfigManager.files_version[path]["server_last_update"] < server_file.last_update)
    # download and replace client file from server
    server_file.download(true)
    # update the files config with latest server_last_update date from server
    ConfigManager.update_files_version(path, "server_last_update", server_file.last_update)
    ConfigManager.update_files_version(path, "local_last_update", local_file.last_update)
  else
    raise "Your config seems to be inconsistent with the server"
  end
end

def check_all
  Files::ServerFile.all.each do |file|
    check file
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

