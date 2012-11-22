$:.unshift File.join(Dir.pwd, 'lib')

require 'listen'
require 'file_server'
require 'base64'


def client_path
  "/Users/pwu/Workarea/tmp/abc"
end

def create_folders_for path
  path = File.dirname(path)

  return if File.directory?(path)
  create_folders_for(path)
  Dir::mkdir(path)
end

def write_file path, file_content
  create_folders_for path
  File.open(path, 'w'){|f| f.write(Base64.decode64(file_content))}
end


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









# file_monitor = Thread.start do
# 	Listen.to("/Users/pwu/Workarea/tmp/abc") do |modified, added, removed|

# 	  if !modified.empty?
# 	  	puts "this file is modified: #{modified}"
# 	  end

# 	  if !added.empty?
# 	  	puts "this file is added: #{added}"
# 	  end

# 	  if !removed.empty?
# 	  	puts "this file is removed: #{removed}"
# 	  end
# 	end
# end


