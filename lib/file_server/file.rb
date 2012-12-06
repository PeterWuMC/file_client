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

  end # end of class File

end