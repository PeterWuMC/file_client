class ConfigManager
  require 'file_manager'

  # PATH
  # - server last update
  # - client last update
  def self.files_version
    @@files_version ||= self.load_config_file("version")
  end

  def self.config
    @@config        ||= self.load_config_file("setup")
  end

  def self.load_config_file file_name
    return {} if !FileManager.exists?(:full, config_full_path(file_name), false)
    YAML.load(FileManager.read_from(:full, config_full_path(file_name))) || {}
  end

  def self.update_file_version key, field, value
    field = case field.to_s
      when "client"
        "local_last_update"
      when "server"
        "server_last_update"
      end
    files_version[key] = {} if !files_version[key]
    files_version[key][field] = value
  end

  def self.save_files_version
    FileManager.write_to(:full, config_full_path("version"), files_version.to_yaml, overwrite: true)
  end

  def self.delete_file_version key
    @@files_version.delete key
  end

  def self.config_full_path file_name
    File.join(Dir.pwd, "config/#{file_name}.yml")
  end

  def self.get_config data
    data = config[data.to_s]
    raise "Application is not initialized, please do all necessary setup" unless data

    data
  end
end
