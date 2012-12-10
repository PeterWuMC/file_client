module Files

  class LocalFile

    attr_reader :path, :key

    def initialize path, key
      @path = path
      @key  = key
    end

    def last_update
      FileManager.last_update(:client, @path)
    end

    def file_content
      FileManager.read_from(:client, @path, base64: true)
    end

    def self.find key
      path = Base64.strict_decode64 key
      FileManager.exists?(:client, path, false) ? self.new(path, key) : false
    rescue
      false
    end

    def self.all
      FileManager.all_files(:client).map {|path| self.new(path)}
    end

  end

end
