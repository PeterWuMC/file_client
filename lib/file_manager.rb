class FileManager
  require 'config_manager'
  require 'base64'

  def self.write_to(target, path, file_content, attr={})
    path = get_file_full_path(target, path)

    raise "File already exists: #{path}" if exists?(target, path, false) && !attr[:overwrite]

    write_file(path, attr[:base64] ? Base64.decode64(file_content) : file_content)
    # puts "downloaded: #{path}"
    return path
  end

  def self.read_from(target, path, attr={})
    exists? target, path

    path = get_file_full_path(target, path)

    file_content = File.read(path)
    attr[:base64] ? Base64.encode64(file_content) : file_content
  end

  def self.exists?(target, path, raise_exception=true)
    path = get_file_full_path(target, path)

    if File.exists?(path)
      return true
    else
      raise "File not found: #{path}" if raise_exception
      return false
    end
  end

  def self.last_update(target, path)
    exists? target, path

    path = get_file_full_path(target, path)

    DateTime.parse(File.mtime(path).to_s)
  end

  def self.all_files(target, path="")
    path = get_file_full_path(target, path)

    Dir["#{path}/**/*"].select{|v| File.file?(v)}.map{|v| v.gsub!(/^#{path}\//, "")}
  end


  private

    def self.get_file_full_path target, path
      target.to_s == "client" ? File.join(ConfigManager.get_config(:client_folder), path) : path
    end

    def self.create_folders_for path
      path = File.dirname(path)

      return if File.directory?(path) || ["/", "."].include?(path)
      create_folders_for(path)
      Dir::mkdir(path)
    end

    def self.write_file path, file_content
      create_folders_for path
      File.open(path, 'w'){|f| f.write(file_content)}
    end

end
