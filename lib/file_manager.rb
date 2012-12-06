class FileManager
  require 'config_manager'

  def self.write_to_file path, file_content, overwrite=false
    path = File.join(client_path, path)
    raise "file already exists: #{path}" if File.exists?(path) && !overwrite
    self.write_file(path, file_content)
    puts "downloaded: #{path}"
  end


  private
    def self.client_path
      client_folder = ConfigManager.client_path
      raise "application is not initialized, please do all necessart setup" unless client_folder

      client_folder
    end

    def self.create_folders_for path
      path = File.dirname(path)

      return if File.directory?(path)
      create_folders_for(path)
      Dir::mkdir(path)
    end

    def self.write_file path, file_content
      create_folders_for path
      File.open(path, 'w'){|f| f.write(Base64.decode64(file_content))}
    end

end