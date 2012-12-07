module Files

  class ServerFile < ReactiveResource::Base

    self.format = :json
    self.site = ConfigManager.get_config(:server_path)
    self.primary_key = :path


    def download overwrite=false
      FileManager.write_to(:client, self.path, self.get(:download)["file_content"], {overwrite: true, base64: true})
    end

    def check
      last_update = DateTime.parse(self.last_update)
      path        = self.path
      if ConfigManager.files_version[path] && ConfigManager.files_version[path]["server_last_update"] == last_update
        # do nothing
      elsif !ConfigManager.files_version[path] || (ConfigManager.files_version[path] && ConfigManager.files_version[path]["server_last_update"] < last_update)
        # download and replace client file from server
        self.download(true)

        local_file = Files::LocalFile.find(self.path)
        # update the files config with latest server_last_update date from server
        ConfigManager.update_files_version(path, "server_last_update", last_update)
        ConfigManager.update_files_version(path, "client_last_update", local_file.last_update)
      else
        raise "Your config seems to be inconsistent with the server"
      end
    end

    def self.check_all
      self.all.each do |file|
        file.check
      end
      ConfigManager.save_files_version

    end

  end # end of class ServerFile

end
