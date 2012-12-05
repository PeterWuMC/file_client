module FileServer

  class File < ReactiveResource::Base

    self.format = :json
    self.site = "http://localhost:1234/"
    self.primary_key = :path

  end

end