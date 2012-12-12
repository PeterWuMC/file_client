module Files

  class ServerFile < ReactiveResource::Base

    self.format = :json
    self.site = ConfigManager.get_config(:server_path)
    self.primary_key = :key

    def self.find(*arguments)
      super(*arguments)
    rescue ActiveResource::ResourceNotFound
      false
    end

    def last_update
      DateTime.parse attributes[:last_update].to_s
    end

    def download overwrite=false
      FileManager.write_to(:local, self.path, self.get(:download)["file_content"], {overwrite: true, base64: true})
      local_file = Files::LocalFile.find self.key
      ConfigManager.update_file_version self.key, :server, self.last_update
      ConfigManager.update_file_version local_file.key, :local, local_file.last_update

      ConfigManager.save_files_version
      Log.this(1, "[DOWNLOADED] #{self.path}")
    end

  end # end of class ServerFile

end
