module Files

  class LocalFile

    attr_reader :path, :key

    def initialize path
      @path = path
      @key  = Base64.strict_encode64 path
    end

    def last_update
      FileManager.last_update(:client, @path)
    end

    def file_content
      FileManager.read_from(:client, @path, base64: true)
    end

    def self.find path
      FileManager.exists?(:client, path, false) ? self.new(path) : false
    end

    def self.all
      FileManager.all_files(:client).map {|path| self.new(path)}
    end

  end

end
