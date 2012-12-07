module Files

	class LocalFile

    attr_reader :path

    def initialize path
      @path = path
    end

    def last_update
      FileManager.last_update(:client, @path)
    end

    def file_content
      FileManager.read_from(:client, @path, base64: true)
    end

    def self.find path
      FileManager.exists? :client, path

      self.new(path)
    end

  end

end