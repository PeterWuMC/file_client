$:.unshift File.join(Dir.pwd, 'models')
$:.unshift File.join(Dir.pwd, 'lib')

require 'listen'
require 'files'
require 'base64'
require 'yaml'
require 'config_manager'




def initialize_this

  initialize_files

  # monitor_files
end


# check if we need to download / replace files
def initialize_files
  # do a scan on current client folder
  # client_files = Hash[*Dir["#{client_path}/**/*"].select{|v| File.file?(v)}.map{|v| [v.gsub(/^#{client_path}/, ""), File.mtime(v)]}.flatten]
  # client_files.each do |path, last_update|
  #   if ConfigManager.files_version[path] && ConfigManager.files_version[path]["client_last_update"] >= last_update
  #     # consistent data between the client directory and the config
  #   elsif ConfigManager.files_version[path] && ConfigManager.files_version[path]["client_last_update"] < last_update
  #     # there are new changes of the file, check with server and upload
  #     # @@jobs_queue.push "upload to server"
  #   else
  #     # new file, check with server and upload
  #     # @@jobs_queue.push "upload to server"
  #   end
  # end
  # ####### Assuming client will not change the file
  # check server file and local, assuming the previous scan would have updated the server
  Files::ServerFile.check_all
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

initialize_this

