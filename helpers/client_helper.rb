def initialize_config
  # will delete all the files if the yml file is not correct
  # FileUtils.rm_rf(client_path) unless YAML.load(File.read(File.join(Dir.pwd, "config/version.yml")))
  @@files_version ||= load_config_file("version")
  @@config        ||= load_config_file("setup")

  # every files that not in the yaml will be treated as a new file
  # unless if it is on the server then will have conflict?
  # should we use md5?
end

def load_config_file file_name
  YAML.load(File.read(config_full_path(file_name))) || {}
end

def client_path
  client_folder = @@config["client_folder"]
  raise "application is not initialized, please do all necessart setup" unless client_folder

  client_folder
end

def files_version
  @@files_version
  # PATH
  # - server last update
  # - client last update
end

def update_files_version
  File.open(config_full_path("version"), 'w'){|f| f.write(files_version.to_yaml)}
end


# file system

def config_full_path file_name
  File.join(Dir.pwd, "config/#{file_name}.yml")
end

def create_folders_for path
  path = File.dirname(path)

  return if File.directory?(path)
  create_folders_for(path)
  Dir::mkdir(path)
end

def write_file path, file_content
  create_folders_for path
  File.open(path, 'w'){|f| f.write(Base64.decode64(file_content))}
end