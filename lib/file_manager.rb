class FileManager
  require 'config_manager'

  def self.write_to(target, path, file_content, attr={})
    path = get_file_full_path(target, path)

    raise "File already exists: #{path}" if File.exists?(path) && !attr[:overwrite]

    write_file(path, attr[:base64] ? Base64.decode64(file_content) : file_content)
    puts "downloaded: #{path}"
    return path
  end

  def self.read_from(target, path, attr={})
    path = get_file_full_path(target, path)

    exists? path

    file_content = File.read(path)
    attr[:base64] ? Base64.encode64(file_content) : file_content
  end

  def self.exists?(target, path)
    path = get_file_full_path(target, path)

    raise "File not found: #{path}" if File.exists?(path)
  end

  def last_update(target, path)
    path = get_file_full_path(target, path)

    exists? path

    DateTime.parse(File.mtime(path).to_s)
  end


  private

    def self.get_file_full_path target, path
      target.to_s == "client" ? File.join(ConfigManager.get(:client_folder), path) : path
    end

    def self.create_folders_for path
      path = File.dirname(path)

      return if File.directory?(path)
      create_folders_for(path)
      Dir::mkdir(path)
    end

    def self.write_file path, file_content
      create_folders_for path
      File.open(path, 'w'){|f| f.write(file_content)}
    end

end