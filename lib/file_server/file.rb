module FileServer

  class File < ReactiveResource::Base
    require 'file_manager'
    require 'config_manager'

    self.format = :json
    self.site = ConfigManager.get(:server_path)
    self.primary_key = :path


    def download overwrite=false
      FileManager.write_to_client_file self.path, self.get(:download)["file_content"], overwrite
    end

    def check
      last_update = DateTime.parse(self.last_update)
      path        = self.path
      if ConfigManager.files_version[path] && ConfigManager.files_version[path]["server_last_update"] == last_update
        # do nothing
      elsif !ConfigManager.files_version[path] || (ConfigManager.files_version[path] && ConfigManager.files_version[path]["server_last_update"] < last_update)
        # download and replace client file from server
        self.download(true)
        # update the files config with latest server_last_update date from server
        ConfigManager.update_files_version(path, "server_last_update", last_update)
      else
        raise "Your config seems to be inconsistent with the server"
      end
    end

    def self.check_all
      File.all.each do |file|
        file.check
      end
    end

  end # end of class File

end