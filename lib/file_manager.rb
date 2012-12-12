class FileManager
  require 'config_manager'
  require 'base64'

  def self.write_to(target, path, file_content, attr={})
    full_path = get_file_full_path(target, path)

    raise "File already exists: #{full_path}" if exists?(target, full_path, false) && !attr[:overwrite]

    write_file(full_path, attr[:base64] ? Base64.decode64(file_content) : file_content)
    # puts "downloaded: #{full_path}"
    return full_path
  end

  def self.read_from(target, path, attr={})
    exists? target, path

    full_path = get_file_full_path(target, path)

    file_content = File.read(full_path)
    attr[:base64] ? Base64.encode64(file_content) : file_content
  end

  def self.delete(target, path)
    exists? target, path
    full_path = get_file_full_path(target, path)

    File.delete(full_path)
  end

  def self.exists?(target, path, raise_exception=true)
    full_path = get_file_full_path(target, path)

    if File.exists?(full_path)
      return true
    else
      raise "File not found: #{full_path}" if raise_exception
      return false
    end
  end

  def self.last_update(target, path)
    exists? target, path

    full_path = get_file_full_path(target, path)

    DateTime.parse(File.mtime(full_path).utc.to_s)
  end

  def self.all_files(target, path="")
    full_path = get_file_full_path(target, path)

    Dir["#{full_path}/**/*"].select{|v| File.file?(v)}.map{|v| v.gsub!(/^#{full_path}\//, "")}
  end

  def key_for path
    Base64.strict_encode64 path
  end

  def path_for target, key
    full_path = get_file_full_path(target, Base64.strict_decode64(key))
  end


  private

    def self.get_file_full_path target, path
      target.to_s == "local" ? File.join(ConfigManager.get_config(:local_folder), path) : path
    end

    def self.create_folders_for full_path
      full_path = File.dirname(full_path)

      return if File.directory?(full_path) || ["/", "."].include?(full_path)
      create_folders_for(full_path)
      Dir::mkdir(full_path)
    end

    def self.write_file full_path, file_content
      create_folders_for full_path
      File.open(full_path, 'w'){|f| f.write(file_content)}
    end

end
