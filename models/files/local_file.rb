module Files

  class LocalFile

    attr_reader :path, :key

    def initialize path, key
      @path = path
      @key  = key
    end

    def last_update
      FileManager.last_update(:local, self.path)
    end

    def file_content
      FileManager.read_from(:local, self.path, base64: true)
    end

    def self.find key
      path = Base64.strict_decode64 key
      FileManager.exists?(:local, path, false) ? new(path, key) : false
    rescue
      false
    end

    def self.all
      FileManager.all_files(:local).map {|path| new(path, Base64.strict_encode64(path))}
    end

    def upload
      server_file = Files::ServerFile.find(self.key)
      if server_file
        server_file.update_attribute(:file_content, FileManager.read_from(:local, self.path, base64: true))
      else
        Files::ServerFile.create(path: self.path, file_content: FileManager.read_from(:local, self.path, base64: true))
      end
      server_file = Files::ServerFile.find(self.key)

      ConfigManager.update_file_version self.key, :local, self.last_update
      ConfigManager.update_file_version server_file.key, :server, server_file.last_update

      ConfigManager.save_files_version

      Log.this(1, "[UPLOADED] #{self.path}")
    end

  end

end
