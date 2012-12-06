class ConfigManager


  # PATH
  # - server last update
  # - client last update
  def self.files_version
    @@files_version ||= load_config_file("version")
  end

  def self.config
    @@config        ||= load_config_file("setup")
  end

  def self.load_config_file file_name
    YAML.load(File.read(config_full_path(file_name))) || {}
  end



  def self.update_files_version
    File.open(config_full_path("version"), 'w'){|f| f.write(files_version.to_yaml)}
  end

  def self.config_full_path file_name
    File.join(Dir.pwd, "config/#{file_name}.yml")
  end

  def self.get data
    data = config[data.to_s]
    raise "application is not initialized, please do all necessary setup" unless data

    data
  end
end