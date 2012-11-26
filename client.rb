$:.unshift File.join(Dir.pwd, 'lib')

require 'listen'
require 'file_server'
require 'base64'
require 'yaml'

require_relative 'helpers/cllient_helper'

def initialize
  initialize_config
  initialize_files
  # check files
  monitor files
end


# check if we need to download / replace files
def initialize_files
  all_files = FileServer::File.all
  server_files_hash = Hash[*all_files.map{|f| [f.path, DateTime.parse(f.last_update)]}.flatten]

  # do a scan on current client folder
  client_files = Hash[*Dir["#{client_path}/**/*"].select{|v| File.file?(v)}.map{|v| [v.gsub(/^#{client_path}/, ""), File.mtime(v)]}.flatten]
  client_files.each do |path, last_update|
    if files_version[path] && files_version[path]["client_last_update"] >= last_update
      # consistent data between the client direct and the config
    elsif files_version[path] && files_version[path]["client_last_update"] < last_update
      # there are new changes of the file, check with server and upload
    else
      # new file, check with server and upload
    end
  end

  # if files_version == server_files_hash
end



def download_all_files
  all_files = FileServer::File.all

  all_files.each do |file|
    path = File.join(client_path, file.path)

    if File.exists? path
      puts "here already: #{path}"
    else
      file_content = FileServer::File.download(file.path)["file"]
      write_file(path, file_content)
      puts "downloaded: #{path}"
    end
  end
end


def monitor_files do
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

